import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Workers/available_jobs_page.dart';
import 'sign_up_worker_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/error_handlers.dart';

class LoginWorkerScreen extends StatefulWidget {
  final String userType;

  const LoginWorkerScreen({super.key, this.userType = 'worker'});

  @override
  LoginWorkerScreenState createState() => LoginWorkerScreenState();
}

class LoginWorkerScreenState extends State<LoginWorkerScreen>
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
      // Store values locally to avoid ancestor lookup issues
      final String userName = worker?.name ?? 'عامل';
      final String userEmail = worker?.email ?? _emailController.text;
      final String userJob = worker?.job ?? 'عامل';
      final BuildContext currentContext = context;

      // Use Future.microtask to defer navigation until the current frame is complete
      Future.microtask(() {
        if (mounted && !_isDisposed) {
          // Use a more direct navigation approach
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
            (route) => false, // Remove all previous routes
          );
        }
      });
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

    // Store form values to avoid context issues after async operations
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      // Get auth provider only once and store locally
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = await authProvider.loginAsWorker(email, password);

      // After await, check again if still mounted
      if (!mounted || _isDisposed) return;

      if (success) {
        final worker = authProvider.worker;

        // Show success message with a delayed callback to ensure it completes
        if (mounted && !_isDisposed) {
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
        }

        // Check for worker ID issues
        if (worker?.id == null) {
          print('Worker ID is null after login: ${worker?.toJson()}');
          if (mounted && !_isDisposed) {
            // Use a simple dialog instead of a custom one that might cause issues
            final BuildContext dialogContext = context;
            showDialog(
              context: dialogContext,
              barrierDismissible: false,
              builder:
                  (ctx) => AlertDialog(
                    title: Text('تنبيه'),
                    content: Text(
                      'تم تسجيل الدخول ولكن هناك مشكلة في معرف الحساب.',
                    ),
                    actions: [
                      TextButton(
                        child: Text('حسناً'),
                        onPressed: () {
                          if (mounted && !_isDisposed) {
                            Navigator.of(ctx).pop();
                            _navigateToAvailableJobs(dialogContext, worker);
                          }
                        },
                      ),
                    ],
                  ),
            );
            return;
          }
        }

        // Safe navigation with delay to allow previous UI updates to complete
        if (mounted && !_isDisposed) {
          // Use a short delay instead of microtask for better visual feedback
          Future.delayed(Duration(milliseconds: 800), () {
            if (mounted && !_isDisposed) {
              _navigateToAvailableJobs(context, worker);
            }
          });
        }
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
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        return !_isLoading;
      },
      child: ErrorBoundary(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 40),

                  // App Logo
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.handyman,
                          size: 50,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    'مرحباً بك مجدداً',
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'سجل دخولك للوصول إلى الوظائف المتاحة',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'example@gmail.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'من فضلك أدخل البريد الإلكتروني';
                      } else if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      ).hasMatch(value)) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          _safeSetState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'من فضلك أدخل كلمة المرور';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen
                      },
                      child: Text('نسيت كلمة المرور؟'),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'تسجيل الدخول',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                  // Sign Up Link
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  if (mounted && !_isDisposed) {
                                    final currentContext = context;
                                    Future.microtask(() {
                                      if (mounted && !_isDisposed) {
                                        Navigator.pushReplacement(
                                          currentContext,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => SignUpWorkerScreen(),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                },
                        child: Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Divider with text
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        context,
                        icon: Icons.facebook,
                        color: Color(0xFF3b5998),
                        onTap: () {},
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        context,
                        icon: Icons.g_mobiledata,
                        color: Color(0xFFDB4437),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
