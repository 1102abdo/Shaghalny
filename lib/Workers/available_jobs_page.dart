import 'package:flutter/material.dart';
import 'worker_profile.dart'; // تأكد إنك مكوّن الصفحة دي ومسميها كده
import 'settings_page.dart'; // تأكد من استيراد صفحة الإعدادات

class AvailableJobsPage extends StatelessWidget {
  final String userName;

  const AvailableJobsPage({required this.userName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً، $userName'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    'مرحباً بك!',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('الملف الشخصي'),
              onTap: () {
                Navigator.pop(context); // يغلق الدروار
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerProfilePage(
                      userName: userName,
                      userEmail: 'example@email.com', // تقدر تعدل حسب البيانات اللي معاك
                      userJob: 'غير محدد',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('الإعدادات'),
              onTap: () {
                Navigator.pop(context); // يغلق الدروار
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  SettingsPage(), // الانتقال إلى صفحة الإعدادات
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('تسجيل الخروج'),
              onTap: () {
                Navigator.pop(context); // إغلاق القائمة
                Navigator.pop(context); // الرجوع لشاشة تسجيل الدخول
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'لا توجد بيانات حالياً',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
