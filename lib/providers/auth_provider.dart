import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shaghalny/models/user_model.dart';
import 'package:shaghalny/models/worker_model.dart';
import 'package:shaghalny/services/api_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

enum UserType {
  employer,
  worker,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserType? _userType;
  User? _user;
  Worker? _worker;
  final _storage = const FlutterSecureStorage();

  AuthStatus get status => _status;
  UserType? get userType => _userType;
  User? get user => _user;
  Worker? get worker => _worker;

  AuthProvider() {
    // Check if user is already logged in
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: 'jwt');
    final userTypeStr = await _storage.read(key: 'user_type');
    
    if (token != null && userTypeStr != null) {
      _userType = userTypeStr == 'employer' ? UserType.employer : UserType.worker;
      _status = AuthStatus.authenticated;
      // We could fetch user details here if needed
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }

  Future<bool> loginAsEmployer(String email, String password) async {
    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );
      
      if (response['status'] == 200 && response['data'] != null) {
        _user = User.fromJson(response['data']);
        _userType = UserType.employer;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'employer');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAsWorker(String email, String password) async {
    try {
      final response = await ApiService.loginWorker(
        email: email,
        password: password,
      );
      
      if (response['status'] == 200 && response['data'] != null) {
        _worker = Worker.fromJson(response['data']);
        _userType = UserType.worker;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'worker');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAsEmployer({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String company,
  }) async {
    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        company: company,
      );
      
      if (response['status'] == 201 && response['data'] != null) {
        _user = User.fromJson(response['data']);
        _userType = UserType.employer;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'employer');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerAsWorker({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String job,
  }) async {
    try {
      final response = await ApiService.registerWorker(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        job: job,
      );
      
      if (response['status'] == 201 && response['data'] != null) {
        _worker = Worker.fromJson(response['data']);
        _userType = UserType.worker;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'worker');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_userType == UserType.employer) {
        await ApiService.logout();
      } else if (_userType == UserType.worker) {
        await ApiService.logoutWorker();
      }
    } catch (e) {
      // Even if API call fails, we still want to log out locally
    }
    
    _user = null;
    _worker = null;
    _userType = null;
    _status = AuthStatus.unauthenticated;
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user_type');
    notifyListeners();
  }
}
