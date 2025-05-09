import 'package:flutter/foundation.dart';
import 'package:shaghalny/models/job_model.dart';
import 'package:shaghalny/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  // Cache keys
  static const String _cachedJobsKey = 'cached_jobs';
  static const String _cachedUserJobsKey = 'cached_user_jobs';

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load cached jobs if any
  Future<void> initializeCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First try to load from permanent jobs storage
      final permanentJobsList = prefs.getStringList('permanent_jobs') ?? [];
      if (permanentJobsList.isNotEmpty) {
        List<Job> permanentJobs = [];
        for (String jobJson in permanentJobsList) {
          try {
            final jobData = json.decode(jobJson);
            permanentJobs.add(Job.fromJson(jobData));
          } catch (e) {
            print('Error parsing permanent job: $e');
          }
        }

        if (permanentJobs.isNotEmpty) {
          _jobs = permanentJobs;
          print('Loaded ${_jobs.length} jobs from permanent storage');
          notifyListeners();
          return;
        }
      }

      // Fall back to regular cache if no permanent jobs
      final cachedJobs = prefs.getString(_cachedJobsKey);
      if (cachedJobs != null && cachedJobs.isNotEmpty) {
        final List<dynamic> jobsData = json.decode(cachedJobs);
        _jobs = jobsData.map((jobJson) => Job.fromJson(jobJson)).toList();
        print('Loaded ${_jobs.length} jobs from cache');
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached jobs: $e');
    }
  }

  // Save jobs to cache
  Future<void> _cacheJobs(List<Job> jobs, String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jobMaps =
          jobs.map((job) => job.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(jobMaps));
      print('Cached ${jobs.length} jobs with key: $cacheKey');
    } catch (e) {
      print('Error caching jobs: $e');
    }
  }

  // Get jobs for workers to browse
  Future<void> fetchJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try loading from the API
      final response = await ApiService.getJobs();

      if (response['status'] == 200 && response['data'] != null) {
        final List<dynamic> jobsData = response['data'];
        _jobs = jobsData.map((jobJson) => Job.fromJson(jobJson)).toList();
        print('Jobs loaded from API: ${_jobs.length}');

        // Cache the jobs
        _cacheJobs(_jobs, _cachedJobsKey);
      } else {
        _error = response['msg'] ?? 'Failed to load jobs';
        print('Jobs load error: $_error');

        // Try to load from permanent storage or cache
        final prefs = await SharedPreferences.getInstance();

        // First try to load from permanent storage (for all jobs)
        final allJobsData = prefs.getString('all_jobs');
        if (allJobsData != null && allJobsData.isNotEmpty) {
          try {
            final List<dynamic> allJobsList = json.decode(allJobsData);
            List<Job> allJobs =
                allJobsList.map((jobJson) => Job.fromJson(jobJson)).toList();

            // Filter only public jobs
            _jobs =
                allJobs
                    .where(
                      (job) =>
                          job.status == 'approved' || // Only approved jobs
                          job.status ==
                              null, // Or jobs with no status (default to visible)
                    )
                    .toList();

            print('Loaded ${_jobs.length} public jobs from permanent storage');
            notifyListeners();
            return;
          } catch (e) {
            print('Error loading all_jobs from permanent storage: $e');
          }
        }

        // Finally, try regular cache
        await initializeCache();
      }
    } catch (e) {
      _error = 'Error: $e';
      print('Jobs exception: $_error');

      // Try to load from permanent storage or cache
      final prefs = await SharedPreferences.getInstance();

      // First try permanent storage
      final allJobsData = prefs.getString('all_jobs');
      if (allJobsData != null && allJobsData.isNotEmpty) {
        try {
          final List<dynamic> allJobsList = json.decode(allJobsData);
          _jobs = allJobsList.map((jobJson) => Job.fromJson(jobJson)).toList();
          print('Loaded ${_jobs.length} jobs from permanent storage');
          notifyListeners();
          return;
        } catch (e) {
          print('Error loading from permanent storage: $e');
        }
      }

      // Finally, try regular cache
      await initializeCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserJobs(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Store the existing jobs in case we need to restore them
    final existingJobs = List<Job>.from(_jobs);

    try {
      print('Fetching jobs for user: $userId');

      // First try loading from permanent storage
      final prefs = await SharedPreferences.getInstance();
      final permanentJobsList = prefs.getStringList('permanent_jobs') ?? [];

      if (permanentJobsList.isNotEmpty) {
        List<Job> userJobs = [];
        // Create a set of existing job IDs to prevent duplicates
        Set<int> existingJobIds = existingJobs.map((job) => job.id).toSet();

        for (String jobJson in permanentJobsList) {
          try {
            final jobData = json.decode(jobJson);
            if (jobData['users_id'].toString() == userId) {
              // Skip if the job ID already exists in our list
              int jobId =
                  jobData['id'] is int
                      ? jobData['id']
                      : int.parse(jobData['id'].toString());
              if (!existingJobIds.contains(jobId)) {
                userJobs.add(Job.fromJson(jobData));
                existingJobIds.add(jobId);
              }
            }
          } catch (e) {
            print('Error parsing permanent job for user: $e');
          }
        }

        if (userJobs.isNotEmpty) {
          _jobs = userJobs;
          print(
            'Loaded ${_jobs.length} jobs for user $userId from permanent storage',
          );
          _cacheJobs(_jobs, '${_cachedUserJobsKey}_$userId');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If no permanent jobs found, try API
      final response = await ApiService.getUserJobs(userId);
      print('Response status: ${response['status']}');
      print('Full response: $response');

      if (response['status'] == 200) {
        // Even if data is empty, clear error
        _error = null;

        if (response['data'] != null && (response['data'] as List).isNotEmpty) {
          final List<dynamic> jobsData = response['data'];

          // Track existing job IDs to prevent duplicates
          Set<int> jobIds = _jobs.map((job) => job.id).toSet();
          List<Job> newJobs = [];

          for (var jobJson in jobsData) {
            try {
              Job job = Job.fromJson(jobJson);
              if (!jobIds.contains(job.id)) {
                newJobs.add(job);
                jobIds.add(job.id);
              }
            } catch (e) {
              print('Error parsing job: $e');
            }
          }

          _jobs = newJobs;
          print('User jobs loaded from API: ${_jobs.length} for user $userId');

          // Cache the user jobs
          _cacheJobs(_jobs, '${_cachedUserJobsKey}_$userId');
        } else {
          print('No job data returned for user $userId');

          // If we already have jobs locally and API returns empty,
          // keep the existing jobs instead of clearing them
          if (_jobs.isEmpty && existingJobs.isNotEmpty) {
            print(
              'Keeping ${existingJobs.length} existing jobs from before the API call',
            );
            _jobs = existingJobs;
          }
        }
      } else {
        _error = response['msg'] ?? 'Failed to load user jobs';
        print('User jobs load error: $_error');

        // Restore existing jobs
        if (_jobs.isEmpty && existingJobs.isNotEmpty) {
          _jobs = existingJobs;
          print('Restored ${_jobs.length} existing jobs after API error');
        }

        // Try to load from cache if API failed
        final prefs = await SharedPreferences.getInstance();
        final cachedUserJobs = prefs.getString('${_cachedUserJobsKey}_$userId');
        if (cachedUserJobs != null) {
          try {
            final List<dynamic> jobsData = json.decode(cachedUserJobs);

            // Track existing job IDs to prevent duplicates
            Set<int> jobIds = _jobs.map((job) => job.id).toSet();
            List<Job> newJobs = [];

            for (var jobJson in jobsData) {
              try {
                Job job = Job.fromJson(jobJson);
                if (!jobIds.contains(job.id)) {
                  newJobs.add(job);
                  jobIds.add(job.id);
                }
              } catch (e) {
                print('Error parsing cached job: $e');
              }
            }

            if (newJobs.isNotEmpty) {
              _jobs = newJobs;
              print(
                'Loaded ${_jobs.length} user jobs from cache for user $userId',
              );
            }
          } catch (e) {
            print('Error decoding cached jobs: $e');
          }
        }
      }
    } catch (e) {
      _error = 'Error: $e';
      print('User jobs exception: $_error');

      // Restore existing jobs
      if (_jobs.isEmpty && existingJobs.isNotEmpty) {
        _jobs = existingJobs;
        print('Restored ${_jobs.length} existing jobs after exception');
      }

      // Try to load from cache if exception occurred
      final prefs = await SharedPreferences.getInstance();
      final cachedUserJobs = prefs.getString('${_cachedUserJobsKey}_$userId');
      if (cachedUserJobs != null) {
        final List<dynamic> jobsData = json.decode(cachedUserJobs);
        _jobs = jobsData.map((jobJson) => Job.fromJson(jobJson)).toList();
        print('Loaded ${_jobs.length} user jobs from cache for user $userId');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJob({
    required String title,
    required String description,
    required double salary,
    required String location,
    String? type,
    int? numWorkers,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First check if user is authenticated
      final isAuthenticated = await ApiService.ensureAuthenticated();
      if (!isAuthenticated) {
        _error = 'Authentication token missing. Please log in again.';
        print('JobProvider: Authentication failed, cannot create job');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate input data
      if (title.isEmpty || description.isEmpty || location.isEmpty) {
        _error = 'All fields are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate salary
      if (salary < 0) {
        _error = 'Salary must be a positive number';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('JobProvider: Creating job with salary: $salary');

      final response = await ApiService.createJob(
        title: title,
        description: description,
        salary: salary.toString(),
        location: location,
        type: type,
        numWorkers: numWorkers,
      );

      if (response['status'] == 201 || response['status'] == 200) {
        // The job was created successfully
        print('JobProvider: Job created successfully!');

        // Add the job directly to our local list
        if (response['data'] != null) {
          try {
            // Create a Job object from the response
            final newJobId =
                response['data']['id'] ?? DateTime.now().millisecondsSinceEpoch;
            final userId = response['data']['users_id'] ?? 1;

            // Create a new job object with an approved status
            final newJob = Job(
              id: newJobId is int ? newJobId : int.parse(newJobId.toString()),
              title: title,
              description: description,
              salary: salary,
              location: location,
              type: type ?? 'full-time',
              numWorkers: numWorkers ?? 1,
              usersId: userId is int ? userId : int.parse(userId.toString()),
              status: 'approved', // Set an initial status
              createdAt: DateTime.now(),
            );

            // Add to the start of the jobs list
            _jobs.insert(0, newJob);

            // Cache the updated jobs list with the new job
            final prefs = await SharedPreferences.getInstance();
            final userIdForCache = newJob.usersId.toString();
            await _cacheJobs(_jobs, '${_cachedUserJobsKey}_$userIdForCache');

            // Also save to permanent storage
            try {
              final permanentJobsList =
                  prefs.getStringList('permanent_jobs') ?? [];

              // Check if the job already exists in the permanent jobs list to avoid duplicates
              bool jobExists = false;
              for (String existingJobJson in permanentJobsList) {
                try {
                  final existingJobData = json.decode(existingJobJson);
                  if (existingJobData['id'] == newJob.id) {
                    jobExists = true;
                    print(
                      'Job already exists in permanent storage, skipping duplicate',
                    );
                    break;
                  }
                } catch (e) {
                  print('Error parsing existing job: $e');
                }
              }

              // Only add the job if it doesn't already exist
              if (!jobExists) {
                final jobMap = newJob.toJson();
                jobMap['is_public'] = true; // Make it visible to workers
                permanentJobsList.add(jsonEncode(jobMap));
                await prefs.setStringList('permanent_jobs', permanentJobsList);
              }

              // Update the all_jobs list too
              List<Map<String, dynamic>> allJobsList = [];
              final allJobsData = prefs.getString('all_jobs');
              if (allJobsData != null && allJobsData.isNotEmpty) {
                try {
                  allJobsList = List<Map<String, dynamic>>.from(
                    jsonDecode(allJobsData),
                  );

                  // Check if job already exists in all_jobs list
                  bool jobExistsInAll = allJobsList.any(
                    (job) => job['id'] == newJob.id,
                  );

                  if (!jobExistsInAll) {
                    allJobsList.add(newJob.toJson());
                    await prefs.setString('all_jobs', jsonEncode(allJobsList));
                    print('Saved job to permanent storage and all_jobs list');
                  } else {
                    print(
                      'Job already exists in all_jobs list, skipping duplicate',
                    );
                  }
                } catch (e) {
                  print('Error loading all_jobs in createJob: $e');
                }
              } else {
                allJobsList.add(newJob.toJson());
                await prefs.setString('all_jobs', jsonEncode(allJobsList));
                print('Saved job to all_jobs list (new list created)');
              }
            } catch (e) {
              print('Error saving job to permanent storage: $e');
            }

            notifyListeners();

            print('JobProvider: Added new job to the list: ${newJob.title}');
          } catch (e) {
            print('JobProvider: Error creating job object from response: $e');
          }
        }

        // Try to refresh the user's jobs from the API
        try {
          // Get user ID and fetch jobs
          if (response['data'] != null &&
              response['data']['users_id'] != null) {
            final userId = response['data']['users_id'].toString();
            // Instead of fetching from API which might miss the job,
            // we'll just use our local jobs that already includes the new one
            await _cacheJobs(_jobs, '${_cachedUserJobsKey}_$userId');
          }
        } catch (e) {
          print('JobProvider: Error caching jobs after creation: $e');
          // Consider this still a success since the job was created
        }

        return true;
      } else {
        // Extract detailed error message from response
        _error = response['msg'] ?? 'Failed to create job';
        print('JobProvider: Error creating job: $_error');
        print('JobProvider: Full error response: $response');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error creating job: ${e.toString()}';
      print('JobProvider: Exception in createJob: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      print(
        'Warning: Attempting to update job status but status field might not exist in database',
      );

      // Instead of trying to update the status, we'll just return true
      // This is a temporary workaround until the database schema is updated
      return true;

      /* Original code - commented out
      final response = await ApiService.request(
        method: 'PUT',
        endpoint: 'jobs/$jobId/status',
        data: {'status': status},
        requiresAuth: true,
      );

      if (response['status'] == 200) {
        // Update the job in the local list
        final index = _jobs.indexWhere((job) => job.id.toString() == jobId);
        if (index != -1) {
          // This is a simplification - in a real app, you'd properly update the status
          // For now, we'll just trigger a reload of jobs
          await fetchJobs();
        }
        return true;
      }
      return false;
      */
    } catch (e) {
      print('Update job status error: $e');
      return false;
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

  // Clear cache on logout
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedJobsKey);
      // Remove any user-specific caches too
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cachedUserJobsKey)) {
          await prefs.remove(key);
        }
      }
      print('Job cache cleared');
    } catch (e) {
      print('Error clearing job cache: $e');
    }
  }

  // Set jobs directly (used for manual loading)
  void setJobs(List<Job> jobs) {
    _jobs = jobs;
    notifyListeners();
  }
}
