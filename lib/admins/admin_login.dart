import 'package:flutter/material.dart';
import 'package:shaghalny/admins/dashboard_screen.dart';
import 'package:shaghalny/services/api_service.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.request(
        method: 'POST',
        endpoint: 'admin/login',
        requiresAuth: false,
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response['status'] == 200 && response['data'] != null) {
        // Store admin token
        if (response['data']['token'] != null) {
          await ApiService.storeAdminToken(response['data']['token']);

          // Check if user has admin role
          if (response['data']['role'] == 'admin') {
            // Navigate to admin dashboard
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else {
            setState(() {
              _errorMessage = 'غير مصرح: مطلوب صلاحيات المسؤول';
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = response['msg'] ?? 'فشل تسجيل الدخول. حاول مرة أخرى.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل دخول المسؤول'),
        backgroundColor: Color(0xFFFF9800),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 100,
                  color: Color(0xFFFF9800),
                ),
                SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني للمسؤول',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'تسجيل الدخول كمسؤول',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
