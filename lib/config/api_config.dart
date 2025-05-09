import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String? _customDevUrl;

  // Allow setting a custom development URL
  static Future<void> setCustomDevUrl(String url) async {
    _customDevUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_dev_url', url);
  }

  // Get the saved custom URL if any
  static Future<String?> getCustomDevUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_dev_url');
  }

  static Future<String> getBaseUrl() async {
    if (kReleaseMode) {
      // Production URL - replace with your actual production API URL when deploying
      return 'https://your-production-api.com/api';
    }

    // Check for custom development URL first
    final customUrl = await getCustomDevUrl();
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }

    // Development URLs
    if (Platform.isAndroid) {
      if (!kIsWeb) {
        // Default Android development URLs
        final String host =
            const bool.fromEnvironment('USE_PHYSICAL_DEVICE')
                ? '192.168.1.9' // Default local network IP
                : '10.0.2.2'; // Android emulator localhost
        return 'http://$host:8000/api';
      }
    }

    // Default to localhost for iOS simulator and other platforms
    return 'http://localhost:8000/api';
  }
}
