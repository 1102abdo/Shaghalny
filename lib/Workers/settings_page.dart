import 'package:flutter/material.dart';
import '../components/settings_content.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإعدادات'), backgroundColor: Colors.orange),
      body: SettingsContent(),
    );
  }
}
