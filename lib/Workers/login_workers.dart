import 'package:flutter/material.dart';
import 'available_jobs_page.dart'; // تأكد من المسار
import 'sign_up_workers.dart'; // تأكد من المسار الصحيح

class LoginWorkers extends StatefulWidget {
  final String userType;

  const LoginWorkers({super.key, required this.userType});

  @override
  LoginWorkersState createState() => LoginWorkersState();
}

class LoginWorkersState extends State<LoginWorkers> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        if (!mounted) return;

        // رسالة نجاح بشكل أنيق
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('تم تسجيل الدخول بنجاح كـ ${widget.userType}'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // الانتقال لصفحة الوظائف المتاحة
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => AvailableJobsPage(userName: _emailController.text),
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
        title: Text('تسجيل الدخول'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Icon(Icons.business, size: 100, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  'تسجيل الدخول (${widget.userType})',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'من فضلك أدخل البريد الإلكتروني';
                    }
                    // Format check
                    else if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'صيغة البريد الإلكتروني غير صحيحة';
                    }
                    // Domain existence check (example: require Gmail)
                    else if (!value.endsWith('@gmail.com')) {
                      // ← Add this
                      return 'يجب استخدام بريد جيميل صحيح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'من فضلك أدخل كلمة المرور';
                    } else if (value.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    } else if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
                    } else if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'يجب أن تحتوي على رقم واحد على الأقل';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // زر تسجيل الدخول
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                // رابط الانتقال لصفحة التسجيل
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpWorkers(),
                        ),
                      );
                    },
                    child: Text(
                      'ليس لديك حساب؟ أنشئ حسابًا الآن',
                      style: TextStyle(fontSize: 16, color: Colors.orange),
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
