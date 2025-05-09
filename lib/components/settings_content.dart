import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final _settingsService = SettingsService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isNotificationsEnabled = true;
  String _selectedLanguage = 'ar';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final notificationsEnabled =
          await _settingsService.getNotificationsEnabled();
      final language = await _settingsService.getLanguage();
      setState(() {
        _isNotificationsEnabled = notificationsEnabled;
        _selectedLanguage = language;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تغيير كلمة المرور'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'كلمة المرور الحالية'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  final success = await _settingsService.changePassword(
                    currentPassword: _currentPasswordController.text,
                    newPassword: _newPasswordController.text,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل تغيير كلمة المرور')),
                    );
                  }
                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                },
                child: Text('حفظ'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.password, color: Colors.orange),
            title: Text('تغيير كلمة المرور'),
            onTap: _showChangePasswordDialog,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language, color: Colors.orange),
            title: Text('اللغة'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await _settingsService.setLanguage(value);
                  setState(() => _selectedLanguage = value);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('تم تغيير اللغة')));
                }
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.orange),
            title: Text('الإشعارات'),
            trailing: Switch(
              value: _isNotificationsEnabled,
              activeColor: Colors.orange,
              onChanged: (value) async {
                await _settingsService.setNotificationsEnabled(value);
                setState(() => _isNotificationsEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
