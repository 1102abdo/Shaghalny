import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:file_picker/file_picker.dart';

class ApplicationPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const ApplicationPage({super.key, required this.job});

  @override
  ApplicationPageState createState() => ApplicationPageState();
}

class ApplicationPageState extends State<ApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String? _cvPath;

  // ignore: non_constant_identifier_names
  Future<void> _uploadCV(dynamic FilePicker, dynamic FileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    
    if (result != null) {
      setState(() {
        _cvPath = result.files.single.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقديم على ${widget.job['title']}'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الوظيفة
                Text(
                  'معلومات الوظيفة:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 10),
                _buildInfoRow('الشركة:', widget.job['company']),
                _buildInfoRow('الموقع:', widget.job['location']),
                Divider(height: 30),

                // حقول الإدخال
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم بالكامل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    hintText: 'example@domain.com',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'مطلوب';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'بريد إلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                    hintText: '01XXXXXXXXX',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'مطلوب';
                    if (!RegExp(r'^01[0-2,5]\d{8}$').hasMatch(value)) {
                      return 'يجب أن يبدأ بـ 010/011/012/015';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _experienceController,
                  decoration: InputDecoration(
                    labelText: 'سنوات الخبرة',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: 3 سنوات',
                  ),
                  validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _skillsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'المهارات',
                    border: OutlineInputBorder(),
                    hintText: 'مثال: Flutter, Firebase, API Integration',
                  ),
                  validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                ),
                SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () => _uploadCV(FilePicker, FileType),
                  icon: Icon(Icons.upload),
                  label: Text('رفع السيرة الذاتية (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                if (_cvPath != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'تم رفع: ${_cvPath!.split('/').last}',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم إرسال طلبك بنجاح!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('إرسال الطلب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }
}