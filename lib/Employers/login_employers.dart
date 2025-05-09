import 'package:flutter/material.dart';
import 'package:shaghalny/services/api_service.dart';
import 'package:shaghalny/admins/dashboard_screen.dart';
import 'sign_up_employers.dart'; // استيراد صفحة التسجيل
import 'create_project.dart'; // استيراد صفحة إنشاء المشروع
// استيراد صفحة الملف الشخصي
// import '../services/api_service.dart';

class LoginEmployers extends StatefulWidget {
  final String userType;

  const LoginEmployers({super.key, required this.userType});

  @override
  LoginEmployersState createState() => LoginEmployersState();
}

class LoginEmployersState extends State<LoginEmployers> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try admin login first
      final adminResponse = await ApiService.request(
        method: 'POST',
        endpoint: 'admin/login',
        requiresAuth: false,
        data: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (adminResponse['status'] == 200 &&
          adminResponse['data'] != null &&
          adminResponse['data']['role'] == 'admin') {
        // Store admin token
        await ApiService.storeAdminToken(adminResponse['data']['token']);

        if (!mounted) return;

        // Navigate to admin dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        return;
      }

      // If not admin, try employer login
      final response = await ApiService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response['status'] == 200 && response['data'] != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تسجيل الدخول بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        String userName = response['data']['name'] ?? emailController.text;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateProject(userName: userName),
          ),
        );
      } else {
        if (!mounted) return;

        setState(() {
          _errorMessage = response['msg'] ?? 'فشل تسجيل الدخول. حاول مرة أخرى.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل تسجيل الدخول: ${_errorMessage}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'حدث خطأ: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل دخول صاحب الشغل'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // البريد الإلكتروني
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                  // Domain existence check (example: require Gmail)
                  else if (!value.endsWith('@gmail.com')) {
                    // ← Add this
                    return 'يجب استخدام بريد جيميل صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // كلمة المرور
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
              const SizedBox(height: 32),

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

              const SizedBox(height: 32),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          : Text('تسجيل دخول'),
                ),
              ),
              const SizedBox(height: 16),

              // رابط للتسجيل إذا ليس لديك حساب
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpEmployers()),
                  );
                },
                child: Text(
                  'ليس لديك حساب؟ سجل هنا',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
