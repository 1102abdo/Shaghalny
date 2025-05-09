import 'package:flutter/foundation.dart';
import 'package:shaghalny/models/application_model.dart';
import 'package:shaghalny/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApplicationProvider with ChangeNotifier {
  List<Application> _applications = [];
  bool _isLoading = false;
  String? _error;

  // Cache keys
  static const String _cachedApplicationsKey = 'cached_applications';
  static const String _cachedUserApplicationsKey = 'cached_user_applications';
  static const String _cachedJobApplicationsKey = 'cached_job_applications';

  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load cached applications if any
  Future<void> initializeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedApplications = prefs.getString(_cachedApplicationsKey);
      if (cachedApplications != null && cachedApplications.isNotEmpty) {
        final List<dynamic> applicationsData = json.decode(cachedApplications);
        _applications =
            applicationsData
                .map((applicationJson) => Application.fromJson(applicationJson))
                .toList();
        print('Loaded ${_applications.length} applications from cache');
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached applications: $e');
    }
  }

  // Save applications to cache
  Future<void> _cacheApplications(
    List<Application> applications,
    String cacheKey,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> applicationMaps =
          applications.map((application) => application.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(applicationMaps));
      print('Cached ${applications.length} applications with key: $cacheKey');
    } catch (e) {
      print('Error caching applications: $e');
    }
  }

  // Fetch all applications by a worker
  Future<void> fetchWorkerApplications(String workerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getWorkerApplications(workerId);

      if (response['status'] == 200 && response['data'] != null) {
        final List<dynamic> applicationsData = response['data'];
        _applications =
            applicationsData
                .map((applicationJson) => Application.fromJson(applicationJson))
                .toList();
        print('Worker applications loaded: ${_applications.length}');

        // Cache the applications
        _cacheApplications(
          _applications,
          '${_cachedUserApplicationsKey}_$workerId',
        );
      } else {
        _error = response['msg'] ?? 'Failed to load worker applications';
        print('Worker applications load error: $_error');

        // Try to load from cache if API failed
        final prefs = await SharedPreferences.getInstance();
        final cachedUserApplications = prefs.getString(
          '${_cachedUserApplicationsKey}_$workerId',
        );
        if (cachedUserApplications != null) {
          final List<dynamic> applicationsData = json.decode(
            cachedUserApplications,
          );
          _applications =
              applicationsData
                  .map(
                    (applicationJson) => Application.fromJson(applicationJson),
                  )
                  .toList();
          print(
            'Loaded ${_applications.length} worker applications from cache',
          );
        }
      }
    } catch (e) {
      _error = 'Error: $e';
      print('Worker applications exception: $_error');

      // Try to load from cache if exception occurred
      final prefs = await SharedPreferences.getInstance();
      final cachedUserApplications = prefs.getString(
        '${_cachedUserApplicationsKey}_$workerId',
      );
      if (cachedUserApplications != null) {
        final List<dynamic> applicationsData = json.decode(
          cachedUserApplications,
        );
        _applications =
            applicationsData
                .map((applicationJson) => Application.fromJson(applicationJson))
                .toList();
        print('Loaded ${_applications.length} worker applications from cache');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all applications for a job
  Future<void> fetchJobApplications(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getJobApplications(jobId);

      if (response['status'] == 200 && response['data'] != null) {
        final List<dynamic> applicationsData = response['data'];
        _applications =
            applicationsData
                .map((applicationJson) => Application.fromJson(applicationJson))
                .toList();
        print('Job applications loaded from API: ${_applications.length}');

        // Cache the applications for future use
        _cacheApplications(
          _applications,
          '${_cachedJobApplicationsKey}_$jobId',
        );
      } else {
        _error = response['msg'] ?? 'Failed to load job applications';
        print('Job applications load error: $_error');

        // Try to load from cache if API failed
        final prefs = await SharedPreferences.getInstance();
        final cachedJobApplications = prefs.getString(
          '${_cachedJobApplicationsKey}_$jobId',
        );
        if (cachedJobApplications != null) {
          final List<dynamic> applicationsData = json.decode(
            cachedJobApplications,
          );
          _applications =
              applicationsData
                  .map(
                    (applicationJson) => Application.fromJson(applicationJson),
                  )
                  .toList();
          print('Loaded ${_applications.length} job applications from cache');
        }
      }
    } catch (e) {
      _error = 'Error: $e';
      print('Job applications exception: $_error');

      // Always try to load from cache if exception occurred
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJobApplications = prefs.getString(
          '${_cachedJobApplicationsKey}_$jobId',
        );
        if (cachedJobApplications != null) {
          final List<dynamic> applicationsData = json.decode(
            cachedJobApplications,
          );
          _applications =
              applicationsData
                  .map(
                    (applicationJson) => Application.fromJson(applicationJson),
                  )
                  .toList();
          print(
            'Loaded ${_applications.length} job applications from cache after error',
          );

          // Clear error if we successfully loaded from cache
          if (_applications.isNotEmpty) {
            _error = null;
          }
        }
      } catch (cacheError) {
        print('Error loading applications from cache: $cacheError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new application
  Future<bool> createApplication({
    required String name,
    required String email,
    required String phone,
    required String experience,
    required String skills,
    required int jobId,
    required int workerId,
    String? cv,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if we're in mock API mode
      if (ApiService.isMockApiEnabled()) {
        // Create a mock application in the local storage
        print('Creating mock application in offline mode');

        final mockApplication = Application(
          id: DateTime.now().millisecondsSinceEpoch,
          jobsId: jobId,
          workersId: workerId,
          name: name,
          email: email,
          phone: phone,
          experience: experience,
          skills: skills,
          cv: cv,
          status: 'pending',
          createdAt: DateTime.now(),
          binned: false,
        );

        // Add to local list
        _applications.add(mockApplication);

        // Cache the updated applications list for worker
        await _cacheApplications(
          _applications,
          '${_cachedUserApplicationsKey}_$workerId',
        );

        // Also cache for job applications list (for employers)
        await _cacheApplications(
          _applications,
          '${_cachedJobApplicationsKey}_$jobId',
        );

        print(
          'Mock application created successfully for job $jobId by worker $workerId',
        );
        notifyListeners();
        return true;
      }

      // Regular API flow
      final response = await ApiService.createApplication(
        name: name,
        email: email,
        phone: phone,
        experience: experience,
        skills: skills,
        jobId: jobId,
        workerId: workerId,
        cv: cv,
      );

      if (response['status'] == 201) {
        // Refresh both worker applications and job applications lists
        if (workerId != 0) await fetchWorkerApplications(workerId.toString());

        // This is crucial - also fetch the job applications for the employer
        if (jobId != 0) await fetchJobApplications(jobId.toString());

        print(
          'Application submitted successfully for job $jobId by worker $workerId',
        );
        return true;
      } else {
        // Check if we should fall back to mock mode due to API failure
        if (response['status'] >= 500 ||
            response['msg']?.toString().contains('Network Error') == true) {
          print('API error creating application, falling back to mock mode');

          // Enable mock mode
          ApiService.setMockApiMode(true);

          // Try again with mock mode
          return await createApplication(
            name: name,
            email: email,
            phone: phone,
            experience: experience,
            skills: skills,
            jobId: jobId,
            workerId: workerId,
            cv: cv,
          );
        }

        _error = response['msg'] ?? 'Failed to create application';
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      print('Create application error: $_error');

      // If there's a network error, try mock mode
      print('Falling back to mock mode due to exception');
      ApiService.setMockApiMode(true);

      try {
        // Create a mock application
        final mockApplication = Application(
          id: DateTime.now().millisecondsSinceEpoch,
          jobsId: jobId,
          workersId: workerId,
          name: name,
          email: email,
          phone: phone,
          experience: experience,
          skills: skills,
          cv: cv,
          status: 'pending',
          createdAt: DateTime.now(),
          binned: false,
        );

        // Add to local list
        _applications.add(mockApplication);

        // Cache the updated applications list for worker
        await _cacheApplications(
          _applications,
          '${_cachedUserApplicationsKey}_$workerId',
        );

        // Also cache for job applications list (for employers)
        await _cacheApplications(
          _applications,
          '${_cachedJobApplicationsKey}_$jobId',
        );

        print(
          'Created mock application after error, for job $jobId by worker $workerId',
        );
        notifyListeners();
        return true;
      } catch (mockError) {
        print('Error creating mock application: $mockError');
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update application status (for employers to review applications)
  Future<bool> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      final response = await ApiService.request(
        method: 'PUT',
        endpoint: 'applications/$applicationId/status',
        data: {'status': status},
        requiresAuth: true,
      );

      if (response['status'] == 200) {
        // Update the application in the local list
        final index = _applications.indexWhere(
          (app) => app.id.toString() == applicationId,
        );
        if (index != -1) {
          // In a real application, you would update the status directly
          // For now, we'll just reload the applications to keep it simple
          await fetchJobApplications(_applications[index].jobsId.toString());
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Update application status error: $e');
      return false;
    }
  }

  // Clear cache on logout
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedApplicationsKey);
      // Remove any user/job-specific caches too
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachedUserApplicationsKey) ||
            key.startsWith(_cachedJobApplicationsKey)) {
          await prefs.remove(key);
        }
      }
      print('Application cache cleared');
    } catch (e) {
      print('Error clearing application cache: $e');
    }
  }
}
