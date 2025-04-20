import 'package:flutter/material.dart';
import 'package:shaghalny/Screens/ChooseUserType.dart';
import 'LoginScreen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
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
            ),
            SizedBox(height: 16),

            // المهنة
            TextFormField(
              controller: jobController,
              decoration: InputDecoration(
                labelText: 'المهنة',
                prefixIcon: Icon(Icons.work),
              ),
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
            ),
            SizedBox(height: 32),

            // زر التسجيل
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(userType: 'worker'),
                    ),
                  );
                },
                child: Text('سجّل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 16),

            // رابط لتسجيل الدخول إذا كان المستخدم يمتلك حساب
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
    );
  }
}
