import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Update this to your actual API URL
  //static const String _baseUrl = 'http://YOUR_COMPUTER_IP:8000/api'; // For Android emulator
  static const String _baseUrl =
      'http://localhost:8000/api'; // For iOS simulator

  static final _storage = const FlutterSecureStorage();
  static String? _jwt;

  static Future<void> _loadToken() async {
    _jwt = await _storage.read(key: 'jwt');
  }

  static Future<Map<String, dynamic>> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth) {
      await _loadToken();
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _jwt != null) {
      headers['Authorization'] = 'Bearer $_jwt';
    }

    try {
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers,
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers,
            body: data != null ? jsonEncode(data) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: headers,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${responseData['msg'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // User Authentication
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String company,
  }) async {
    final response = await request(
      method: 'POST',
      endpoint: 'register',
      requiresAuth: false,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'company': company,
      },
    );

    if (response['data'] != null && response['data']['token'] != null) {
      await _storage.write(key: 'jwt', value: response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await request(
      method: 'POST',
      endpoint: 'login',
      requiresAuth: false,
      data: {'email': email, 'password': password},
    );

    if (response['data'] != null && response['data']['token'] != null) {
      await _storage.write(key: 'jwt', value: response['data']['token']);
    }

    return response;
  }

  static Future<void> logout() async {
    await request(method: 'POST', endpoint: 'logout', requiresAuth: true);

    await _storage.delete(key: 'jwt');
  }

  // Worker Authentication
  static Future<Map<String, dynamic>> registerWorker({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String job,
  }) async {
    final response = await request(
      method: 'POST',
      endpoint: 'worker/register',
      requiresAuth: false,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'job': job,
      },
    );

    if (response['data'] != null && response['data']['token'] != null) {
      await _storage.write(key: 'jwt', value: response['data']['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> loginWorker({
    required String email,
    required String password,
  }) async {
    final response = await request(
      method: 'POST',
      endpoint: 'worker/login',
      requiresAuth: false,
      data: {'email': email, 'password': password},
    );

    if (response['data'] != null && response['data']['token'] != null) {
      await _storage.write(key: 'jwt', value: response['data']['token']);
    }

    return response;
  }

  static Future<void> logoutWorker() async {
    await request(
      method: 'POST',
      endpoint: 'worker/logout',
      requiresAuth: true,
    );

    await _storage.delete(key: 'jwt');
  }

  // Jobs
  static Future<Map<String, dynamic>> getJobs() async {
    return await request(method: 'GET', endpoint: 'jobs', requiresAuth: true);
  }

  static Future<Map<String, dynamic>> getUserJobs(String userId) async {
    return await request(
      method: 'GET',
      endpoint: 'users/$userId',
      requiresAuth: true,
    );
  }

  // Workers
  static Future<Map<String, dynamic>> getWorkers() async {
    return await request(
      method: 'GET',
      endpoint: 'workers',
      requiresAuth: true,
    );
  }

  // Applications
  static Future<Map<String, dynamic>> getJobApplications(String jobId) async {
    return await request(
      method: 'GET',
      endpoint: 'applications/$jobId',
      requiresAuth: true,
    );
  }

  // Projects/Jobs Management
  static Future<bool> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String budget,
    required String location,
  }) async {
    try {
      await request(
        method: 'PUT',
        endpoint: 'jobs/$projectId',
        requiresAuth: true,
        data: {
          'title': title,
          'description': description,
          'salary': budget,
          'location': location,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
