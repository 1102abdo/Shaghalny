import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/Screens/choose_user_type.dart';
import 'package:shaghalny/providers/auth_provider.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الخروج'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'هل تريد تسجيل الخروج؟',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                );

                // Get the auth provider and logout
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                // Dismiss loading dialog and navigate to the welcome screen
                Navigator.of(context).pop();

                // Navigate to choose user type screen and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ChooseUserTypeScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('تسجيل الخروج'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
