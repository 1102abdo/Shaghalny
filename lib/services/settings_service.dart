import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _languageKey = 'app_language';
  static const String _notificationsKey = 'notifications_enabled';

  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ar';
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO: Implement actual password change logic with your backend
    // This is a placeholder that always returns true
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return true;
  }
}
