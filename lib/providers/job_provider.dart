import 'package:flutter/foundation.dart';
import 'package:shaghalny/models/job_model.dart';
import 'package:shaghalny/services/api_service.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getJobs();
      
      if (response['status'] == 200 && response['data'] != null) {
        final List<dynamic> jobsData = response['data'];
        _jobs = jobsData.map((jobJson) => Job.fromJson(jobJson)).toList();
      } else {
        _error = response['msg'] ?? 'Failed to load jobs';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserJobs(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getUserJobs(userId);
      
      if (response['status'] == 200 && response['data'] != null) {
        final List<dynamic> jobsData = response['data'];
        _jobs = jobsData.map((jobJson) => Job.fromJson(jobJson)).toList();
      } else {
        _error = response['msg'] ?? 'Failed to load user jobs';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateJob({
    required String jobId,
    required String title,
    required String description,
    required String budget,
    required String location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await ApiService.updateProject(
        projectId: jobId,
        title: title,
        description: description,
        budget: budget,
        location: location,
      );
      
      if (success) {
        // Refresh the jobs list
        await fetchJobs();
        return true;
      } else {
        _error = 'Failed to update job';
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
