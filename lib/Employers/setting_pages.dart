import 'package:flutter/material.dart';

class SettingPages extends StatelessWidget {
  const SettingPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.password, color: Colors.orange),
              title: Text('تغيير كلمة المرور'),
              onTap: () {
                // إضافة وظيفة تغيير كلمة المرور هنا
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.language, color: Colors.orange),
              title: Text('اللغة'),
              onTap: () {
                // إضافة وظيفة تغيير اللغة هنا
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications, color: Colors.orange),
              title: Text('الإشعارات'),
              onTap: () {
                // إضافة وظيفة للإشعارات هنا
              },
            ),
          ],
        ),
      ),
    );
  }
}
