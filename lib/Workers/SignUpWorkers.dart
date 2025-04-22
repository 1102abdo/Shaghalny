import 'package:flutter/material.dart';
import 'package:shaghalny/Screens/ChooseUserType.dart'; // تأكد من استيراد الصفحة هنا
import 'LoginWorkers.dart';

class SignUpWorkers extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpWorkers> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك أدخل البريد الإلكتروني';
                  } else if (!value.contains('@')) {
                    return 'البريد الإلكتروني غير صالح';
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
                  } else if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
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
                  if (value != passwordController.text) {
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // عرض رسالة نجاح صغيرة (SnackBar)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ تم تسجيل الحساب بنجاح'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // الانتقال فورًا لصفحة ChooseUserType
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChooseUserTypeScreen()),
                      );
                    }
                  },
                  child: Text('سجّل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // رابط لتسجيل الدخول إذا عندك حساب
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChooseUserTypeScreen()),
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
