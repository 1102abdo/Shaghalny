import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shaghalny/models/user_model.dart';
import 'package:shaghalny/models/worker_model.dart' as app_models;
import 'package:shaghalny/services/api_service.dart';
import 'package:shaghalny/providers/job_provider.dart';
import 'package:shaghalny/providers/application_provider.dart';
import 'dart:math';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

enum UserType { employer, worker, admin }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserType? _userType;
  User? _user;
  app_models.Worker? _worker;
  final _storage = const FlutterSecureStorage();
  JobProvider? _jobProvider;
  ApplicationProvider? _applicationProvider;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserType? get userType => _userType;
  User? get user => _user;
  app_models.Worker? get worker => _worker;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setJobProvider(JobProvider provider) {
    _jobProvider = provider;
  }

  void setApplicationProvider(ApplicationProvider provider) {
    _applicationProvider = provider;
  }

  AuthProvider() {
    // Check if user is already logged in
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: 'jwt');
    final userTypeStr = await _storage.read(key: 'user_type');

    if (token != null && userTypeStr != null) {
      // Set userType and status based on stored values
      _userType =
          userTypeStr == 'employer' ? UserType.employer : UserType.worker;
      _status = AuthStatus.authenticated;

      // Validate the token is actually working
      try {
        // Use the ApiService to check if the token is valid
        final isValid = await ApiService.ensureAuthenticated();
        if (!isValid) {
          print('Token validation failed during startup - clearing session');
          // If validation fails, clear the token and mark as unauthenticated
          await logout();
          return;
        }
        print('Token successfully validated during startup');
      } catch (e) {
        print('Error validating token during startup: $e');
        // Don't automatically logout on validation error to prevent network issues from logging users out
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> loginAsEmployer(String email, String password) async {
    try {
      final response = await ApiService.login(email: email, password: password);

      if (response['status'] == 200 && response['data'] != null) {
        // Explicitly store the token to ensure it's saved
        final token = response['data']['token'];
        if (token != null) {
          await _storage.write(key: 'jwt', value: token);
          print(
            'Saved JWT token for employer: ${token.substring(0, min(15, token.length))}...',
          );
        } else {
          print('Error: Token is null in login response');
          return false;
        }

        _user = User.fromJson(response['data']);
        _userType = UserType.employer;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'employer');

        // Initialize jobs from cache if the job provider is available
        if (_jobProvider != null) {
          await _jobProvider!.initializeCache();

          // Also load the user's jobs specifically
          if (_user != null) {
            try {
              await _jobProvider!.fetchUserJobs(_user!.id.toString());
              print('Loaded jobs for user ${_user!.id} after login');
            } catch (e) {
              print('Error loading user jobs after login: $e');
            }
          }
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Employer login error: $e');
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
        // Store the token directly from storage
        final token = response['data']['token'];
        if (token != null) {
          await _storage.write(key: 'jwt', value: token);
        }

        _worker = app_models.Worker.fromJson(response['data']);

        // Check if worker has an ID, if not try to extract it from response
        if (_worker!.id == null) {
          print('Warning: Worker ID is null after login, attempting to fix');

          // Try to extract ID from response directly
          if (response['data']['id'] != null) {
            // Create a new worker with the ID from response
            _worker = app_models.Worker(
              id: response['data']['id'],
              name: _worker!.name,
              email: _worker!.email,
              job: _worker!.job,
              banned: _worker!.banned,
              token: _worker!.token,
              createdAt: _worker!.createdAt,
              updatedAt: _worker!.updatedAt,
            );
            print('Fixed worker ID: ${_worker!.id}');
          } else {
            // Try to extract ID from token
            try {
              final extractedId = await ApiService.getUserIdFromToken();
              if (extractedId != null) {
                _worker = app_models.Worker(
                  id: extractedId,
                  name: _worker!.name,
                  email: _worker!.email,
                  job: _worker!.job,
                  banned: _worker!.banned,
                  token: _worker!.token,
                  createdAt: _worker!.createdAt,
                  updatedAt: _worker!.updatedAt,
                );
                print('Extracted worker ID from token: ${_worker!.id}');
              } else {
                print('Failed to extract worker ID from token');
              }
            } catch (e) {
              print('Error extracting worker ID: $e');
            }
          }
        }

        _userType = UserType.worker;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'worker');

        // Initialize jobs from cache if the job provider is available
        if (_jobProvider != null) {
          await _jobProvider!.initializeCache();
        }

        // Initialize applications from cache if the application provider is available
        if (_applicationProvider != null && _worker != null) {
          await _applicationProvider!.initializeCache();
          if (_worker!.id != null) {
            await _applicationProvider!.fetchWorkerApplications(
              _worker!.id.toString(),
            );
          } else {
            print('Worker ID is still null, cannot fetch applications');
          }
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
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
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        company: company,
      );

      if (response['status'] == 201 && response['data'] != null) {
        // Explicitly store the token to ensure it's saved
        final token = response['data']['token'];
        if (token != null) {
          await _storage.write(key: 'jwt', value: token);
          print(
            'Saved JWT token for new employer: ${token.substring(0, min(15, token.length))}...',
          );
        } else {
          print('Warning: Token is null in registration response');
        }

        // Make sure company field is properly set in the response data
        if (response['data']['company'] == null ||
            response['data']['company'].toString().isEmpty) {
          response['data']['company'] = company;
        }

        _user = User.fromJson(response['data']);
        _userType = UserType.employer;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'employer');

        // Initialize jobs from cache if the job provider is available
        if (_jobProvider != null) {
          await _jobProvider!.initializeCache();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Employer registration error: $e');
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
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
        // Store the token directly from storage
        final token = response['data']['token'];
        if (token != null) {
          await _storage.write(key: 'jwt', value: token);
        }

        _worker = app_models.Worker.fromJson(response['data']);
        _userType = UserType.worker;
        _status = AuthStatus.authenticated;
        await _storage.write(key: 'user_type', value: 'worker');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
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

      // Clear job cache if the job provider is available
      if (_jobProvider != null) {
        await _jobProvider!.clearCache();
      }

      // Clear application cache if the application provider is available
      if (_applicationProvider != null) {
        await _applicationProvider!.clearCache();
      }
    } catch (e) {
      // Even if API call fails, we still want to log out locally
      print('Logout error: $e');
    }

    _user = null;
    _worker = null;
    _userType = null;
    _status = AuthStatus.unauthenticated;
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user_type');
    notifyListeners();
  }

  // Method to refresh user data from the API
  Future<bool> refreshUserData() async {
    try {
      // First check if we have a valid token
      final token = await _storage.read(key: 'jwt');
      if (token == null || token.isEmpty) {
        print('No token available for refreshing user data');
        return false;
      }
      
      print('Refreshing user data with token: ${token.substring(0, min(10, token.length))}...');
      
      if (_user == null) {
        print('User is null, cannot determine user ID for refresh');
        // Try to get user ID from token
        final userId = await ApiService.getUserIdFromToken();
        if (userId != null) {
          print('Extracted user ID from token: $userId');
        } else {
          return false;
        }
      }

      // Request user data from API
      final response = await ApiService.request(
        method: 'GET',
        endpoint: 'users/${_user?.id ?? "me"}',
        requiresAuth: true,
      );

      if (response['status'] >= 200 &&
          response['status'] < 300 &&
          response['data'] != null) {
        _user = User.fromJson(response['data']);
        print('User data refreshed successfully: ${_user?.name}, ${_user?.email}, ${_user?.company}');
        notifyListeners();
        return true;
      } else {
        print('Failed to refresh user data: ${response['msg']}');
        return false;
      }
    } catch (e) {
      print('Error refreshing user data: $e');
      return false;
    }
  }
}

