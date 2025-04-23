import 'dart:convert';

import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api.com';
  
  static get http => null;

  static Future<bool> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String budget,
    required String location,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/projects/$projectId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'budget': budget,
          'location': location,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating project: $e');
      }
      return false;
    }
  }
}