import 'package:flutter/material.dart';
import '../components/settings_content.dart';

class SettingPages extends StatelessWidget {
  const SettingPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات'), backgroundColor: Colors.orange),
      body: SettingsContent(),
    );
  }
}
