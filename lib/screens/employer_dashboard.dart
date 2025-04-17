import 'package:flutter/material.dart';

class EmployerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صاحب الشغل'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'مرحباً بك في لوحة تحكم صاحب الشغل!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
