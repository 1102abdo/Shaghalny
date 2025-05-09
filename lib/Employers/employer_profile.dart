import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'employer_applications.dart';
import 'edit_profile.dart';
import 'create_project.dart';
import 'posted_profile.dart';
import 'setting_pages.dart';

class EmployerProfile extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String companyName;

  const EmployerProfile({
    required this.userName,
    required this.userEmail,
    required this.companyName,
    super.key,
  });

  @override
  State<EmployerProfile> createState() => _EmployerProfileState();
}

class _EmployerProfileState extends State<EmployerProfile> {
  String _userName = '';
  String _userEmail = '';
  String _companyName = '';

  @override
  void initState() {
    super.initState();
    // Initial load from widget parameters
    setState(() {
      _userName = widget.userName;
      _userEmail = widget.userEmail;
      _companyName = widget.companyName;
    });
    
    // Then force a refresh from the server
    _forceRefreshUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures data is refreshed when the page becomes visible
    _updateUserInfo();
  }

  void _updateUserInfo() {
    // Get the latest data from auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        _userName = user.name;
        _userEmail = user.email;
        _companyName = user.company.isNotEmpty ? user.company : "Not specified";
      });
      
      // If any data is missing, try to refresh from the server
      if (user.company.isEmpty) {
        authProvider.refreshUserData().then((_) {
          // Update again after refresh
          if (authProvider.user != null) {
            setState(() {
              _userName = authProvider.user!.name;
              _userEmail = authProvider.user!.email;
              _companyName = authProvider.user!.company.isNotEmpty 
                  ? authProvider.user!.company 
                  : "Not specified";
            });
          }
        });
      }
    }
  }

  Future<void> _forceRefreshUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Force refresh from server
      await authProvider.refreshUserData();
      
      // Update UI with fresh data
      if (authProvider.user != null) {
        setState(() {
          _userName = authProvider.user!.name;
          _userEmail = authProvider.user!.email;
          _companyName = authProvider.user!.company.isNotEmpty 
              ? authProvider.user!.company 
              : "Not specified";
        });
        print("Profile data refreshed: $_userName, $_userEmail, $_companyName");
      } else {
        print("User is null after refresh");
      }
    } catch (e) {
      print("Error refreshing user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملف صاحب العمل'),
        backgroundColor: Colors.orange,
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('جاري تحديث البيانات...')),
              );
              _forceRefreshUserData().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تحديث البيانات')),
                );
              });
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
              'اسم صاحب العمل: $_userName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'البريد الإلكتروني: $_userEmail',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('اسم الشركة: $_companyName', style: TextStyle(fontSize: 16)),
            SizedBox(height: 32),

            // تعديل الملف الشخصي
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfile(
                          userName: _userName,
                          userEmail: _userEmail,
                          userJob: _companyName,
                        ),
                  ),
                );

                // Refresh profile data if edit was successful
                if (result == true) {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).refreshUserData();
                  _updateUserInfo();
                }
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
                    builder: (context) => CreateProject(userName: _userName),
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

            // الطلبات المقدمة
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployerApplications(jobId: 0),
                  ),
                );
              },
              icon: Icon(Icons.list_alt),
              label: Text('الطلبات المقدمة'),
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






