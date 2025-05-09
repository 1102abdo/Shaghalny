import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// تأكد من استيراد الصفحة هنا
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/Workers/login_workers.dart';
import 'package:shaghalny/widgets/error_handlers.dart'; // Import error handlers

class SignUpWorkers extends StatefulWidget {
  const SignUpWorkers({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpWorkers>
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

  // Navigate to login screen
  void _navigateToLogin() {
    if (mounted && !_isDisposed) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginWorkers()),
        (route) => false,
      );
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

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.registerAsWorker(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        job: jobController.text,
      );

      // Check if still mounted after awaiting
      if (!mounted || _isDisposed) return;

      if (success) {
        // Check worker ID validity
        final worker = authProvider.worker;
        if (worker?.id == null) {
          print('Warning: Worker created with null ID: ${worker?.toJson()}');

          // We'll continue but display a warning
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ تم التسجيل بنجاح لكن هناك مشكلة في معرف الحساب. قد تحتاج إلى تسجيل الخروج وإعادة تسجيل الدخول.',
              ),
              backgroundColor: Colors.amber,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم تسجيل الحساب بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Short delay before navigation to allow snackbar to be seen
        Future.delayed(Duration(milliseconds: 1200), () {
          if (mounted && !_isDisposed) {
            _navigateToLogin();
          }
        });
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
        if (_isLoading) {
          // Prevent back button when loading
          return false;
        }
        return true;
      },
      child: ErrorBoundary(
        child: Scaffold(
          appBar: AppBar(
            title: Text('إنشاء حساب'),
            backgroundColor: Colors.orange,
          ),
          body: Padding(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

                    // الاسم
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل الاسم';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // المهنة
                    TextFormField(
                      controller: jobController,
                      decoration: InputDecoration(
                        labelText: 'المهنة',
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أدخل المهنة';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // البريد الإلكتروني
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
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
                        // Domain existence check (optional)
                        else if (!value.endsWith('@gmail.com')) {
                          return 'يجب استخدام بريد جيميل صحيح';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // كلمة المرور
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock),
                      ),
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

                    // تأكيد كلمة المرور
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'من فضلك أكد كلمة المرور';
                        } else if (value != passwordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),

                    // زر التسجيل
                    SizedBox(
                      width: double.infinity,
                      child:
                          _isLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              )
                              : ElevatedButton(
                                onPressed: _registerWorker,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text('سجّل'),
                              ),
                    ),
                    SizedBox(height: 16),

                    // رابط لتسجيل الدخول إذا عندك حساب
                    GestureDetector(
                      onTap:
                          _isLoading
                              ? null
                              : () {
                                if (mounted && !_isDisposed) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginWorkers(),
                                    ),
                                  );
                                }
                              },
                      child: Text(
                        'عندك حساب؟ سجل دخول',
                        style: TextStyle(color: Colors.grey[700]),
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
