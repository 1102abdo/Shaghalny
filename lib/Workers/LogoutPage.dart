import 'package:flutter/material.dart';
import 'package:shaghalny/Workers/LoginWorkers.dart'; // تأكد من المسار الصحيح للملف

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الخروج'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // العودة لشاشة تسجيل الدخول بعد الخروج
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginWorkers(userType: 'عامل'), // تأكد من أن LoginScreen يقبل هذا المتغير
              ),
            );
          },
          child: Text('تسجيل الخروج'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // استخدام backgroundColor بدلاً من primary
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

