import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html' as platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/providers/job_provider.dart';
import 'package:shaghalny/providers/application_provider.dart';
import 'package:shaghalny/services/api_service.dart';
import 'package:shaghalny/widgets/error_handlers.dart';
import 'package:shaghalny/debug_screen.dart';
import 'package:shaghalny/Employers/create_project.dart';
import 'package:shaghalny/Screens/login_worker_screen.dart';
import 'package:shaghalny/Screens/sign_up_worker_screen.dart';
import 'package:shaghalny/Screens/splash_screen.dart';
import 'package:shaghalny/Screens/api_test_screen.dart';
import 'Screens/welcome_screen.dart';
import 'dart:io' as io;

void main() {
  // Run the app inside a zone to catch all errors
  runZonedGuarded(
    () {
      // Ensure Flutter binding is initialized - moved inside the zone
      WidgetsFlutterBinding.ensureInitialized();

      // Set up global error handler from ErrorBoundary
      ErrorBoundary.catchGlobalErrors();

      // Set API base URL based on platform
      if (kIsWeb) {
        // For web, use the current hostname with proper port
        final hostname = Uri.base.host; // Get the current hostname
        // Use the Laravel backend server port
        ApiService.setBaseUrl('http://$hostname:8000/api');

        // During development on localhost, you might need this:
        if (hostname == 'localhost' || hostname == '127.0.0.1') {
          ApiService.setBaseUrl('http://localhost:8000/api');
        }
      } else {
        // For mobile platforms
        try {
          if (io.Platform.isAndroid) {
            // Android emulator - 10.0.2.2 is the special IP for the host machine
            ApiService.setBaseUrl('http://10.0.2.2:8000/api');
          } else if (io.Platform.isIOS) {
            // iOS simulator uses localhost
            ApiService.setBaseUrl('http://127.0.0.1:8000/api');
          } else {
            // Other platforms
            ApiService.setBaseUrl('http://localhost:8000/api');
          }
        } catch (e) {
          // Fallback in case platform detection fails
          ApiService.setBaseUrl('http://localhost:8000/api');
          print('Platform detection error: $e');
        }
      }

      // Create providers
      final authProvider = AuthProvider();
      final jobProvider = JobProvider();
      final applicationProvider = ApplicationProvider();

      // Connect the providers
      authProvider.setJobProvider(jobProvider);
      authProvider.setApplicationProvider(applicationProvider);

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => authProvider),
            ChangeNotifierProvider(create: (_) => jobProvider),
            ChangeNotifierProvider(create: (_) => applicationProvider),
          ],
          child: const ShaghalnyApp(),
        ),
      );
    },
    (error, stackTrace) {
      print('Caught error in runZonedGuarded: $error');
      print('Stack trace: $stackTrace');
      // Could add error reporting service here
    },
  );
}

class ShaghalnyApp extends StatelessWidget {
  const ShaghalnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shaghalny',
      themeMode: ThemeMode.light,
      initialRoute: '/',
      theme: ThemeData(
        primaryColor: Color(0xFFFF8A00),
        colorScheme: ColorScheme.light(
          primary: Color(0xFFFF8A00),
          secondary: Color(0xFF2196F3),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: Colors.white,
          error: Colors.red[700]!,
          onSurface: Colors.black87,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: GoogleFonts.cairo().fontFamily,
        textTheme: GoogleFonts.cairoTextTheme().copyWith(
          displayLarge: GoogleFonts.cairo(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displayMedium: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          displaySmall: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
          bodyMedium: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFF8A00),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          shadowColor: Colors.black26,
          titleTextStyle: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF8A00),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: Color(0xFFFF8A00).withOpacity(0.3),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFFFF8A00),
            textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFFFF8A00),
            side: BorderSide(color: Color(0xFFFF8A00), width: 1.5),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFFFF8A00), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Color(0xFFFF8A00).withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          labelStyle: TextStyle(
            color: Color(0xFFFF8A00),
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFFFF8A00).withOpacity(0.2)),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
          space: 24,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Color(0xFFFF8A00),
        ),
      ),
      builder: (context, child) {
        // Add error handling for widget errors
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'حدث خطأ في التطبيق',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'نأسف للإزعاج، يرجى إعادة تشغيل التطبيق',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    if (!kReleaseMode)
                      Text(
                        '${errorDetails.exception}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      child: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          );
        };

        // Add a key to prevent some rebuild errors
        child = KeyedSubtree(key: UniqueKey(), child: child!);

        // Wrap everything in our ErrorBoundary
        return ErrorBoundary(child: child);
      },
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/debug': (context) => DebugScreen(),
        '/create-project': (context) => CreateProject(userName: 'المستخدم'),
        '/login-worker': (context) => LoginWorkerScreen(),
        '/signup-worker': (context) => SignUpWorkerScreen(),
        '/api-test': (context) => ApiTestScreen(),
      },
      // Use a builder with navigator observer for better navigation handling
      navigatorObservers: [_NavigationObserver()],
    );
  }
}

// Custom Navigator observer to handle navigation errors
class _NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('Navigation: Pushed ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('Navigation: Popped ${route.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('Navigation: Removed ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print(
      'Navigation: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}


