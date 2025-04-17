import 'package:flutter/material.dart';

class WorkerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العامل'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'مرحباً بك في لوحة تحكم العامل!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
