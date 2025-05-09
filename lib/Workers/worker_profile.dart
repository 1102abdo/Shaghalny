import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/Screens/choose_user_type.dart';
import 'package:shaghalny/Workers/available_jobs_page.dart';
import 'package:shaghalny/Workers/settings_page.dart';
import 'package:shaghalny/providers/auth_provider.dart';
// import 'package:shaghalny/Workers/available_jobs_page.dart' as settings;
// تأكد من استيراد صفحة تسجيل الخروج
import 'edit_profile_page.dart'; // تأكد من استيراد صفحة تعديل الملف الشخصي

class WorkerProfilePage extends StatefulWidget {
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
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  late String userName;
  late String userEmail;
  late String userJob;

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  void _loadWorkerData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.worker != null) {
      setState(() {
        userName = authProvider.worker!.name;
        userEmail = authProvider.worker!.email;
        userJob = authProvider.worker!.job;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Show logout confirmation dialog
              bool shouldLogout =
                  await showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text('تسجيل الخروج'),
                        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false); // Cancel
                            },
                            child: Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(
                                dialogContext,
                              ).pop(true); // Confirm logout
                            },
                            child: Text(
                              'تسجيل الخروج',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (shouldLogout) {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                );

                // Perform logout
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                // Close loading dialog
                Navigator.of(context).pop();

                // Navigate to choose user type screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ChooseUserTypeScreen(),
                  ),
                  (route) => false,
                );
              }
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
            Text(
              'البريد الإلكتروني: $userEmail',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('المهنة: $userJob', style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // تمرير المعاملات إلى صفحة تعديل الملف الشخصي
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfilePage(
                          userName: userName, // تمرير userName
                          userEmail: userEmail, // تمرير userEmail
                          userJob: userJob, // تمرير userJob
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
                    builder:
                        (context) => AvailableJobsPage(
                          userName: userName,
                          userEmail: '',
                          userJob: '',
                        ),
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
                  MaterialPageRoute(builder: (context) => SettingsPage()),
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
