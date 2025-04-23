import 'package:flutter/material.dart';
import 'package:shaghalny/Employers/login_employers.dart';
import 'package:shaghalny/Screens/choose_user_type.dart'; // تأكد من المسار
// Removed duplicate import of 'login_employers.dart'

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
  final TextEditingController confirmPasswordController = TextEditingController();

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ تم إنشاء حساب صاحب العمل بنجاح'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ChooseUserTypeScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('أنشئ حساب'),
                ),
              ),
              SizedBox(height: 16),

              // عندك حساب؟ سجل دخول
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginEmployers(userType: 'صاحب عمل')), // أو LoginEmployers لو فيه
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
