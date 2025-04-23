import 'package:flutter/material.dart';
import 'sign_up_employers.dart'; // استيراد صفحة التسجيل
import 'create_project.dart'; // استيراد صفحة إنشاء المشروع

class LoginEmployers extends StatefulWidget {
  final String userType;

  const LoginEmployers({super.key, required this.userType});

  @override
  LoginEmployersState createState() => LoginEmployersState();
}

class LoginEmployersState extends State<LoginEmployers> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ تم تسجيل الدخول بنجاح'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // الحصول على البريد الإلكتروني كـ userName
                      String userName = emailController.text;

                      // الانتقال إلى صفحة إنشاء مشروع مع تمرير userName
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CreateProject(userName: userName),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('تسجيل دخول'),
                ),
              ),
              const SizedBox(height: 16),

              // رابط للتسجيل إذا ليس لديك حساب
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpEmployers()),
                  );
                },
                child: Text(
                  'ليس لديك حساب؟ سجل هنا',
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
