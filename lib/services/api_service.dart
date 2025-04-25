import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://yourdomain.com/api';
  static final _storage = FlutterSecureStorage();
  static String? _jwt;

  static Future<void> _loadToken() async {
    _jwt = await _storage.read(key: 'jwt');
  }

  static Future<Map<String, dynamic>> request(
    String method, 
    String endpoint, 
    dynamic data,
  ) async {
    await _loadToken();
    
    try {
      final response = await (method == 'GET'
          ? http.get(
              Uri.parse('$_baseUrl/$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_jwt',
              },
            )
          : http.post(
              Uri.parse('$_baseUrl/$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_jwt',
              },
              body: data != null ? jsonEncode(data) : null,
            ));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  static Future<dynamic> login(String email, String password) async {
    final response = await request('POST', 'login', {
      'email': email,
      'password': password,
    });
    
    await _storage.write(key: 'jwt', value: response['token']);
    return response['user'];
  }

  static Future<Map<String, dynamic>> getJobs() async {
    return await request('GET', 'jobs', null);
  }
  
  // ignore: non_constant_identifier_names
  static FlutterSecureStorage() {}

  static updateProject({required String projectId, required String title, required String description, required String budget, required String location}) {}
}