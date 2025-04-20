import 'package:flutter/material.dart';
import 'workerProfile.dart'; // تأكد من أنك قد قمت بإنشاء هذه الصفحة
// import 'package:shaghalny/Workers/AvailableJobsPage.dart'; // تأكد من أنك قد قمت بإنشاء صفحة الوظائف المتاحة
import 'EditProfilePage.dart';  // استيراد صفحة التعديل بشكل صحيح

class WorkerDashboard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userJob;

  WorkerDashboard({
    required this.userName,
    required this.userEmail,
    required this.userJob,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('لوحة العامل'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            Center(
              child: Icon(Icons.construction, size: 100, color: Colors.orange),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'أهلاً بك في لوحة العامل!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.orange),
                title: Text('الملف الشخصي'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfilePage(
                        userName: userName,
                        userEmail: userEmail,
                        userJob: userJob,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.work_outline, color: Colors.orange),
                title: Text('الوظائف المتاحة'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        userName: userName,
                        userEmail: userEmail,
                        userJob: userJob,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('تسجيل الخروج'),
                trailing: Icon(Icons.exit_to_app),
                onTap: () {
                  Navigator.pop(context); // يعود إلى شاشة تسجيل الدخول
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
