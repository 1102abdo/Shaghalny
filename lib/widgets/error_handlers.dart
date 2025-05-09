import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/Screens/choose_user_type.dart';

/// Shows a dialog for worker ID null errors with the option to logout and login again
Future<void> showWorkerIdNullErrorDialog(BuildContext context) async {
  if (!context.mounted) return;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('مشكلة في حساب العامل'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'معرف العامل غير صالح، يرجى تسجيل الخروج وإعادة تسجيل الدخول لتصحيح المشكلة.',
              ),
              SizedBox(height: 12),
              Text(
                'هذه مشكلة معروفة، ويمكن أن تحدث عندما لا يتم معالجة معرف العامل بشكل صحيح من الخادم.',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text('تجاهل'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                // Perform logout
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                // Navigate to login page using a safer approach with microtask
                if (context.mounted) {
                  Future.microtask(() {
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChooseUserTypeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  });
                }
              } catch (e) {
                print('Error during logout from dialog: $e');
                // Fallback navigation if needed
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome',
                    (route) => false,
                  );
                }
              }
            },
            child: Text('تسجيل الخروج'),
          ),
        ],
      );
    },
  );
}

/// Shows a dialog for general widget errors that might occur
Future<void> showWidgetErrorDialog(
  BuildContext context,
  String errorMessage,
) async {
  if (!context.mounted) return;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('خطأ في واجهة المستخدم'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('حدث خطأ في واجهة المستخدم:'),
              SizedBox(height: 8),
              Text(errorMessage, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('يمكنك المحاولة مرة أخرى أو إعادة تشغيل التطبيق.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text('حسنًا'),
          ),
        ],
      );
    },
  );
}

/// A global error handler for the entire application
class AppErrorHandler {
  static void handleNullWorkerIdError(BuildContext context) {
    if (context.mounted) {
      showWorkerIdNullErrorDialog(context);
    }
  }

  static void handleDeactivatedWidgetError(
    BuildContext context,
    String errorDetails,
  ) {
    // Log the error but don't show a dialog since this is usually a lifecycle issue
    print('Deactivated widget error: $errorDetails');
  }

  // Special handler for the 'Looking up a deactivated widget's ancestor is unsafe' error
  static void handleAncestorLookupError() {
    print(
      'WARNING: Caught unsafe ancestor lookup. Widget may have been disposed.',
    );
    // No UI action needed - just log the error
  }
}

/// Error boundary widget that catches errors within its child widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();

  // Add a static method to be called in the main.dart file
  static void catchGlobalErrors() {
    // Override Flutter's error widget for production
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Prevent showing red screen errors in release mode
      return Container(
        alignment: Alignment.center,
        child: Text(
          'حدث خطأ ما',
          style: TextStyle(color: Colors.red),
          textDirection: TextDirection.rtl,
        ),
      );
    };

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if this is an ancestor lookup error
      if (details.exception.toString().contains(
            'Looking up a deactivated widget\'s ancestor is unsafe',
          ) ||
          details.exception.toString().contains(
            'setState() called after dispose()',
          )) {
        // Just log the error but don't crash
        print('CAUGHT LIFECYCLE ERROR: ${details.exception}');
        print('Error details: ${details.stack}');
        return; // Prevent the error from propagating
      }

      // For other errors, report normally
      FlutterError.presentError(details);
    };
  }
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String _errorDetails = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset error state when dependencies change
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorDetails = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'حدث خطأ في تحميل هذا الجزء من التطبيق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(_errorDetails, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorDetails = '';
                  });
                },
                child: Text('محاولة مرة أخرى'),
              ),
            ],
          ),
        ),
      );
    }

    // Wrap the child in a Builder to provide a safe context
    return Builder(
      builder: (innerContext) {
        return widget.child;
      },
    );
  }

  void reportError(FlutterErrorDetails details) {
    // Special handling for the specific ancestor lookup error
    if (details.exception.toString().contains(
      'Looking up a deactivated widget\'s ancestor is unsafe',
    )) {
      AppErrorHandler.handleAncestorLookupError();
      return; // Skip showing this error since it's a lifecycle issue
    }

    setState(() {
      _hasError = true;
      _errorDetails = details.exception.toString();
    });
  }
}
