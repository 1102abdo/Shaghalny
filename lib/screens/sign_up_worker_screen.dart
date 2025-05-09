import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/Screens/login_worker_screen.dart';
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/widgets/error_handlers.dart';

class SignUpWorkerScreen extends StatefulWidget {
  const SignUpWorkerScreen({super.key});

  @override
  SignUpWorkerScreenState createState() => SignUpWorkerScreenState();
}

class SignUpWorkerScreenState extends State<SignUpWorkerScreen>
    with WidgetsBindingObserver {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    jobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Safe setState that checks if mounted and not disposed
  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }

  // Safe navigation to login screen using a more robust method
  void _navigateToLogin() {
    if (mounted && !_isDisposed) {
      // Store values before navigation to avoid ancestor lookup issues
      final context = this.context;

      // Use Future.microtask to defer navigation until the current frame is complete
      Future.microtask(() {
        // Check again if still mounted before proceeding
        if (mounted && !_isDisposed) {
          // Use static navigation instead of context-based navigation
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginWorkerScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  Future<void> _registerWorker() async {
    // Pre-check to ensure widget is still mounted
    if (!mounted || _isDisposed) return;

    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Store form data in local variables to avoid context issues after async operations
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String passwordConfirmation = confirmPasswordController.text;
    final String job = jobController.text;

    try {
      // Get auth provider only once and store locally
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.registerAsWorker(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        job: job,
      );

      // Check if still mounted after awaiting
      if (!mounted || _isDisposed) return;

      if (success) {
        // Check worker ID validity
        final worker = authProvider.worker;
        if (worker?.id == null) {
          print('Warning: Worker created with null ID: ${worker?.toJson()}');

          // We'll continue but display a warning - using a more stable approach
          if (mounted && !_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚠️ تم التسجيل بنجاح لكن هناك مشكلة في معرف الحساب. قد تحتاج إلى تسجيل الخروج وإعادة تسجيل الدخول.',
                ),
                backgroundColor: Colors.amber,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Show success message
          if (mounted && !_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ تم تسجيل الحساب بنجاح'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        }

        // Navigate after a short delay to allow for success message display
        if (mounted && !_isDisposed) {
          Future.delayed(Duration(milliseconds: 800), () {
            if (mounted && !_isDisposed) {
              _navigateToLogin();
            }
          });
        }
      } else {
        if (!mounted || _isDisposed) return;

        _safeSetState(() {
          _isLoading = false;
          _errorMessage = 'فشل في إنشاء الحساب. حاول مرة أخرى.';
        });
      }
    } catch (e) {
      print('Registration error: $e');

      if (!mounted || _isDisposed) return;

      _safeSetState(() {
        _isLoading = false;
        if (e.toString().contains('email has already been taken')) {
          _errorMessage =
              'البريد الإلكتروني مستخدم بالفعل. الرجاء استخدام بريد آخر.';
        } else {
          _errorMessage = 'حدث خطأ: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_isLoading; // Prevent back button when loading
      },
      child: ErrorBoundary(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('إنشاء حساب', style: TextStyle(color: Colors.black87)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    // Title section
                    Center(
                      child: Text(
                        'انضم كعامل في شغلني',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'أدخل بياناتك للتسجيل وابدأ البحث عن وظائف',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30),

                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Name field
                    _buildInputField(
                      controller: nameController,
                      label: 'الاسم',
                      hint: 'أدخل الاسم الكامل',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل الاسم';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Job field
                    _buildInputField(
                      controller: jobController,
                      label: 'المهنة',
                      hint: 'مثال: نجار، سباك، كهربائي...',
                      icon: Icons.work,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل المهنة';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Email field
                    _buildInputField(
                      controller: emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'example@gmail.com',
                      icon: Icons.email,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
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
                    SizedBox(height: 16),

                    // Password field
                    _buildPasswordField(
                      controller: passwordController,
                      label: 'كلمة المرور',
                      obscureText: _obscurePassword,
                      toggleObscure: () {
                        _safeSetState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل كلمة المرور';
                        } else if (value.length < 8) {
                          return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                        } else if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
                        } else if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'يجب أن تحتوي على رقم واحد على الأقل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Confirm password field
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      obscureText: _obscureConfirmPassword,
                      toggleObscure: () {
                        _safeSetState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أكد كلمة المرور';
                        } else if (value != passwordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),

                    // Register button
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerWorker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: Colors.orange.withOpacity(0.3),
                            ),
                            child: Text(
                              'تسجيل الحساب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    SizedBox(height: 20),

                    // Login link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () {
                                      if (mounted && !_isDisposed) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LoginWorkerScreen(),
                                          ),
                                        );
                                      }
                                    },
                            child: Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for creating text fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextDirection? textDirection,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  // Helper method for creating password fields
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.orange),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }
}
