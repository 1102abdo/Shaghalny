import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userJob;

  const EditProfile({
    required this.userName,
    required this.userEmail,
    required this.userJob,
    Key? key,
  }) : super(key: key);

  @override
  _EditProfileEmployerState createState() => _EditProfileEmployerState();
}

class _EditProfileEmployerState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _jobController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _jobController = TextEditingController(text: widget.userJob);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ التعديلات بنجاح!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الملف الشخصي'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم صاحب الشغل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك أدخل اسم صاحب الشغل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
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
              SizedBox(height: 16),
              TextFormField(
                controller: _jobController,
                decoration: InputDecoration(
                  labelText: 'نوع الشغل أو التخصص',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك أدخل نوع الشغل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('حفظ التعديلات'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
