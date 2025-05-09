import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'available_jobs_page.dart'; // تأكد من المسار
import 'sign_up_workers.dart'; // تأكد من المسار الصحيح
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/widgets/error_handlers.dart'; // Import error handlers
import 'package:shaghalny/admins/dashboard_screen.dart'; // Fixed import path
import 'package:shaghalny/services/api_service.dart';

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
  bool _obscurePassword = true;

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
      final String userName = worker?.name ?? 'عامل';
      final String userEmail = worker?.email ?? _emailController.text;
      final String userJob = worker?.job ?? 'عامل';
      final BuildContext currentContext = context;

      Future.microtask(() {
        if (mounted && !_isDisposed) {
          Navigator.pushAndRemoveUntil(
            currentContext,
            MaterialPageRoute(
              builder:
                  (_) => AvailableJobsPage(
                    userName: userName,
                    userEmail: userEmail,
                    userJob: userJob,
                  ),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  // Handle login process with better error handling
  Future<void> _login() async {
    if (!mounted || _isDisposed) return;

    if (!_formKey.currentState!.validate()) return;

    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Try admin login first
      final adminResponse = await ApiService.request(
        method: 'POST',
        endpoint: 'admin/login',
        requiresAuth: false,
        data: {'email': email, 'password': password},
      );

      if (adminResponse['status'] == 200 &&
          adminResponse['data'] != null &&
          adminResponse['data']['role'] == 'admin') {
        // Store admin token
        await ApiService.storeAdminToken(adminResponse['data']['token']);

        if (!mounted || _isDisposed) return;

        // Navigate to admin dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        return;
      }

      // If not admin, try worker login
      bool success = await authProvider.loginAsWorker(email, password);

      if (!mounted || _isDisposed) return;

      if (success) {
        final worker = authProvider.worker;
        _navigateToAvailableJobs(context, worker);
      } else {
        _safeSetState(() {
          _errorMessage =
              'فشل تسجيل الدخول. تحقق من بيانات الاعتماد الخاصة بك.';
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      _safeSetState(() {
        _errorMessage = 'حدث خطأ: $e';
      });
    } finally {
      if (mounted && !_isDisposed) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
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
            title: Text('تسجيل دخول العامل'),
            backgroundColor: Colors.orange,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.work, size: 100, color: Colors.orange),
                    SizedBox(height: 32),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      obscureText: _obscurePassword,
                      textDirection: TextDirection.ltr,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    SizedBox(height: 24),

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'تسجيل الدخول',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),

                    SizedBox(height: 16),

                    // Sign up link
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpWorkers(),
                          ),
                        );
                      },
                      child: Text(
                        'ليس لديك حساب؟ سجل الآن',
                        style: TextStyle(color: Colors.orange),
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
