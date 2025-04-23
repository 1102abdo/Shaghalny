import 'package:flutter/material.dart';
import 'package:shaghalny/Screens/choose_user_type.dart'; // تأكد من استيراد الصفحة هنا
//import 'login_workers.dart';

class SignUpWorkers extends StatefulWidget {
  const SignUpWorkers({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpWorkers> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء حساب'), backgroundColor: Colors.orange),
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
                        MaterialPageRoute(
                          builder: (context) => ChooseUserTypeScreen(),
                        ),
                      );
                    }
                  },
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
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseUserTypeScreen(),
                    ),
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
