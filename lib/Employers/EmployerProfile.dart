import 'package:flutter/material.dart';
import 'LogoutPage.dart';  // تأكد من استيراد صفحة تسجيل الخروج
import 'EditProfile.dart';  // تأكد من استيراد صفحة تعديل الملف الشخصي
import 'CreateProject.dart'; // صفحة إنشاء مشروع جديد
import 'PostedProfile.dart'; // صفحة عرض المشاريع المنشورة
import 'SettingPages.dart'; // تأكد من استيراد صفحة الإعدادات

class EmployerProfile extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String companyName;

  const EmployerProfile({
    required this.userName,
    required this.userEmail,
    required this.companyName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملف صاحب العمل'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutPages()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.business, size: 100, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'اسم صاحب العمل: $userName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('البريد الإلكتروني: $userEmail', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('اسم الشركة: $companyName', style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            
            // تعديل الملف الشخصي
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(
                      userName: userName,
                      userEmail: userEmail,
                      userJob: companyName,
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

            // إنشاء مشروع جديد
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProject(userName: userName),
                  ),
                );
              },
              icon: Icon(Icons.add_business),
              label: Text('إنشاء مشروع جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 20),

            // عرض المشاريع المنشورة
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostedProfile()),
                );
              },
              icon: Icon(Icons.folder_open),
              label: Text('مشاريعي المنشورة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 20),

            // الإعدادات
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPages()),
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
