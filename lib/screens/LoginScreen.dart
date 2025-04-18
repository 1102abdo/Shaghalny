import 'package:flutter/material.dart';
import 'package:shaghalny/Workers/AvailableJobsPage.dart'; // تأكد من المسار الصحيح

class LoginScreen extends StatefulWidget {
  final String userType; // إضافة الـ parameter الجديد

  LoginScreen({Key? key, required this.userType}) : super(key: key); // تعريف الـ ructor

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed( Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        // هنا نقدر ننقل المستخدم لصفحة تانية بعد تسجيل الدخول بنجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تسجيل الدخول بنجاح كـ ${widget.userType}')),
        );

        // بعد نجاح تسجيل الدخول، سيتم الانتقال إلى AvailableJobsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AvailableJobsPage(userName: _emailController.text), // إرسال بيانات المستخدم
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('تسجيل الدخول'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                 Icon(Icons.lock_outline, size: 100, color: Colors.orange),
                 SizedBox(height: 20),
                Text(
                  'تسجيل الدخول (${widget.userType})', // استخدام الـ userType هنا
                  style:  TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                 SizedBox(height: 16),
                 Text(
                  'ادخل بياناتك لتسجيل الدخول',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                 SizedBox(height: 32),

                // البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'من فضلك أدخل البريد الإلكتروني';
                    } else if (!value.contains('@')) {
                      return 'صيغة البريد غير صحيحة';
                    }
                    return null;
                  },
                ),
                 SizedBox(height: 12),

                // كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration:  InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'من فضلك أدخل كلمة المرور';
                    } else if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر';
                    }
                    return null;
                  },
                ),
                 SizedBox(height: 24),

                // زر تسجيل الدخول
                _isLoading
                    ?  Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding:  EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:  Text(
                            'تسجيل الدخول',
                            style: TextStyle(fontSize: 18),
                          ),
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
