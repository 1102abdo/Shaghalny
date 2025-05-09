import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'available_jobs_page.dart'; // تأكد من المسار
import 'sign_up_workers.dart'; // تأكد من المسار الصحيح
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/widgets/error_handlers.dart'; // Import error handlers

class LoginWorkers extends StatefulWidget {
  final String userType;

  const LoginWorkers({super.key, this.userType = 'worker'});

  @override
  LoginWorkersState createState() => LoginWorkersState();
}

class LoginWorkersState extends State<LoginWorkers>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _emailController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Safe setState that checks if mounted and not disposed
  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  // Helper method to navigate to available jobs
  void _navigateToAvailableJobs(BuildContext context, dynamic worker) {
    if (mounted && !_isDisposed) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (context) => AvailableJobsPage(
                userName: worker?.name ?? 'عامل',
                userEmail: worker?.email ?? _emailController.text,
                userJob: worker?.job ?? 'عامل',
              ),
        ),
        (route) => false, // Remove all previous routes
      );
    }
  }

  // Handle login process with better error handling
  Future<void> _login() async {
    // Pre-check to ensure widget is still mounted
    if (!mounted || _isDisposed) return;

    if (!_formKey.currentState!.validate()) return;

    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = await authProvider.loginAsWorker(
        _emailController.text,
        _passwordController.text,
      );

      // After await, check again if still mounted
      if (!mounted || _isDisposed) return;

      if (success) {
        final worker = authProvider.worker;

        // Show success message with a delayed callback to ensure it completes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('تم تسجيل الدخول بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Check for worker ID issues
        if (worker?.id == null) {
          print('Worker ID is null after login: ${worker?.toJson()}');
          if (mounted && !_isDisposed) {
            await showWorkerIdNullErrorDialog(context);
          }
        }

        // Short delay before navigation to allow snackbar to be seen
        Future.delayed(Duration(milliseconds: 1200), () {
          if (mounted && !_isDisposed) {
            _navigateToAvailableJobs(context, worker);
          }
        });
      } else {
        _safeSetState(() {
          _isLoading = false;
          _errorMessage = 'فشل تسجيل الدخول. تأكد من صحة البيانات.';
        });
      }
    } catch (e) {
      print('Login error: $e');

      if (!mounted || _isDisposed) return;

      _safeSetState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          // Prevent back button when loading
          return false;
        }
        return true;
      },
      child: ErrorBoundary(
        child: Scaffold(
          appBar: AppBar(
            title: Text('تسجيل الدخول'),
            backgroundColor: Colors.orange,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Icon(Icons.business, size: 100, color: Colors.orange),
                    SizedBox(height: 20),
                    Text(
                      'تسجيل الدخول كعامل',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ادخل بياناتك لتسجيل الدخول',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),

                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    // البريد الإلكتروني
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل البريد الإلكتروني';
                        }
                        // Format check
                        else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value)) {
                          return 'صيغة البريد الإلكتروني غير صحيحة';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    // كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل كلمة المرور';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // زر تسجيل الدخول
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),

                    // رابط الانتقال لصفحة التسجيل
                    SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  if (mounted && !_isDisposed) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpWorkers(),
                                      ),
                                    );
                                  }
                                },
                        child: Text(
                          'ليس لديك حساب؟ أنشئ حسابًا الآن',
                          style: TextStyle(fontSize: 16, color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
