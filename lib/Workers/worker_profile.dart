import 'package:flutter/material.dart';
import 'package:shaghalny/Workers/available_jobs_page.dart';
import 'package:shaghalny/Workers/available_jobs_page.dart' as settings;
import 'logout_page.dart';  // تأكد من استيراد صفحة تسجيل الخروج
import 'edit_profile_page.dart';  // تأكد من استيراد صفحة تعديل الملف الشخصي

class WorkerProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userJob;

  const WorkerProfilePage({
    required this.userName,
    required this.userEmail,
    required this.userJob,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.account_circle, size: 100, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'اسم العامل: $userName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('البريد الإلكتروني: $userEmail', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('المهنة: $userJob', style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // تمرير المعاملات إلى صفحة تعديل الملف الشخصي
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      userName: userName,  // تمرير userName
                      userEmail: userEmail, // تمرير userEmail
                      userJob: userJob,     // تمرير userJob
                    ),
                  ),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('تعديل الملف الشخصي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvailableJobsPage(userName: userName, userEmail: '', userJob: '',),
                  ),
                );
              },
              icon: Icon(Icons.work_outline),
              label: Text('عرض الوظائف المتاحة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => settings.SettingsPage()),
                );
              },
              icon: Icon(Icons.settings),
              label: Text('الإعدادات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
