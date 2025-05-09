import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class EditProfile extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userJob;

  const EditProfile({
    required this.userName,
    required this.userEmail,
    required this.userJob,
    super.key,
  });

  @override
  EditProfileEmployerState createState() => EditProfileEmployerState();
}

class EditProfileEmployerState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _jobController;
  bool _isLoading = false;

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

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        // Get the auth provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Create request data
        final data = {
          'name': _nameController.text,
          'email': _emailController.text,
          'company': _jobController.text,
        };

        // Call API to update profile
        final response = await ApiService.updateUserProfile(data);

        if (response['status'] >= 200 && response['status'] < 300) {
          // Refresh user data in the provider
          await authProvider.refreshUserData();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تم حفظ التعديلات بنجاح!')));

          // Return true to indicate successful update
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'فشل في حفظ التعديلات: ${response['message'] ?? 'خطأ غير معروف'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
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
                  labelText: 'اسم صاحب العمل',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك أدخل اسم صاحب العمل';
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
                  labelText: 'اسم الشركة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك أدخل اسم الشركة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('حفظ التعديلات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
