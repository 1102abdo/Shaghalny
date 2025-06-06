import 'package:flutter/material.dart';
import 'package:shaghalny/Employers/login_employers.dart';
// تأكد من المسار
import '../services/api_service.dart';
import 'create_project.dart';

class SignUpEmployers extends StatefulWidget {
  const SignUpEmployers({super.key});

  @override
  SignUpEmployersState createState() => SignUpEmployersState();
}

class SignUpEmployersState extends State<SignUpEmployers> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل صاحب عمل'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode:
              AutovalidateMode.onUserInteraction, // Enable real-time validation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الاسم
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم صاحب العمل',
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

              // اسم الشركة
              TextFormField(
                controller: companyController,
                decoration: InputDecoration(
                  labelText: 'اسم الشركة / المؤسسة',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك أدخل اسم الشركة';
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
                  // Domain existence check (example: require Gmail)
                  else if (!value.endsWith('@gmail.com')) {
                    // ← Add this
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
                    return 'من فضلك أكد كلمة المرور'; // Add empty check
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
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final response = await ApiService.register(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  passwordConfirmation:
                                      confirmPasswordController.text,
                                  company: companyController.text,
                                );

                                if (response['status'] == 201 &&
                                    response['data'] != null) {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ تم إنشاء حساب صاحب العمل بنجاح',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CreateProject(
                                            userName: nameController.text,
                                          ),
                                    ),
                                  );
                                } else {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ فشل إنشاء الحساب: ${response['msg'] ?? 'خطأ غير معروف'}',
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!mounted) return;

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
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('أنشئ حساب'),
                ),
              ),
              SizedBox(height: 16),

              // عندك حساب؟ سجل دخول
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LoginEmployers(userType: 'صاحب عمل'),
                    ), // أو LoginEmployers لو فيه
                  );
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
    );
  }
}
