import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/Workers/application_page.dart';
import 'package:shaghalny/Workers/settings_page.dart';
import 'package:shaghalny/Workers/worker_profile.dart';
import 'package:shaghalny/providers/job_provider.dart';
import 'package:shaghalny/models/job_model.dart';
import 'package:shaghalny/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AvailableJobsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userJob;

  const AvailableJobsPage({
    required this.userName,
    required this.userEmail,
    required this.userJob,
    super.key,
  });

  @override
  State<AvailableJobsPage> createState() => _AvailableJobsPageState();
}

class _AvailableJobsPageState extends State<AvailableJobsPage> {
  late JobProvider _jobProvider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _jobProvider = Provider.of<JobProvider>(context, listen: false);
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      // Try to fetch jobs from the API
      await _jobProvider.fetchJobs();

      // If no jobs are loaded from API, try using the permanent storage
      if (_jobProvider.jobs.isEmpty) {
        print('No jobs returned from API, trying permanent storage');
        await _jobProvider.initializeCache();

        // If still no jobs, enable mock API mode and try again
        if (_jobProvider.jobs.isEmpty) {
          print('Still no jobs, enabling mock API mode');
          // Enable mock API mode to generate sample jobs
          ApiService.setMockApiMode(true);

          // Try fetching jobs again with mock mode enabled
          await _jobProvider.fetchJobs();

          // If still no jobs, try to load from shared preferences
          if (_jobProvider.jobs.isEmpty) {
            print('Still no jobs after mock mode, trying all_jobs in storage');
            await _loadJobsFromAllJobsList();

            // If still empty, create mock jobs manually
            if (_jobProvider.jobs.isEmpty) {
              _createAndStoreMockJobs();
            }
          }
        }
      }
    } catch (e) {
      print('Error loading jobs: $e');
      // Try to load from permanent storage
      await _jobProvider.initializeCache();

      // If still no jobs, enable mock API mode
      if (_jobProvider.jobs.isEmpty) {
        print('Error occurred, enabling mock API mode');
        ApiService.setMockApiMode(true);

        // Try fetching jobs again with mock mode enabled
        try {
          await _jobProvider.fetchJobs();
        } catch (e2) {
          print('Error fetching jobs in mock mode: $e2');
        }

        // If still no jobs, try storage or create mock jobs
        if (_jobProvider.jobs.isEmpty) {
          await _loadJobsFromAllJobsList();

          // If still empty, create mock jobs manually
          if (_jobProvider.jobs.isEmpty) {
            _createAndStoreMockJobs();
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadJobsFromAllJobsList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allJobsData = prefs.getString('all_jobs');

      if (allJobsData != null && allJobsData.isNotEmpty) {
        final List<dynamic> allJobsList = json.decode(allJobsData);
        if (allJobsList.isNotEmpty) {
          final loadedJobs =
              allJobsList.map((jobJson) => Job.fromJson(jobJson)).toList();
          _jobProvider.setJobs(loadedJobs);
          print(
            'Loaded ${loadedJobs.length} jobs directly from all_jobs storage',
          );
        }
      } else {
        print('No jobs found in all_jobs storage');
      }
    } catch (e) {
      print('Error loading from all_jobs storage: $e');
    }
  }

  // Create mock jobs as a last resort
  void _createAndStoreMockJobs() {
    print('Creating mock jobs manually');
    final List<Job> mockJobs = [
      Job(
        id: 1001,
        title: 'نجار لترميم منزل',
        description: 'مطلوب نجار لترميم أبواب ونوافذ منزل',
        salary: 200.0,
        location: 'القاهرة - المعادي',
        type: 'عمل مؤقت',
        numWorkers: 1,
        usersId: 1,
        userName: 'أحمد محمد',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Job(
        id: 1002,
        title: 'سباك لإصلاح حمام',
        description: 'مطلوب سباك لإصلاح تسريب في الحمام',
        salary: 150.0,
        location: 'القاهرة - مدينة نصر',
        type: 'عمل مؤقت',
        numWorkers: 1,
        usersId: 2,
        userName: 'محمود علي',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Job(
        id: 1003,
        title: 'كهربائي لتركيب لمبات',
        description: 'مطلوب كهربائي لتركيب وصيانة الإضاءة',
        salary: 180.0,
        location: 'الجيزة - الدقي',
        type: 'عمل مؤقت',
        numWorkers: 1,
        usersId: 3,
        userName: 'سمير حسن',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];

    // Set the jobs in the provider
    _jobProvider.setJobs(mockJobs);

    // Save to shared preferences
    _saveMockJobsToStorage(mockJobs);
  }

  // Save mock jobs to storage for future use
  Future<void> _saveMockJobsToStorage(List<Job> jobs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jobsJson =
          jobs.map((job) => job.toJson()).toList();
      await prefs.setString('all_jobs', json.encode(jobsJson));
      print('Saved ${jobs.length} mock jobs to storage');
    } catch (e) {
      print('Error saving mock jobs to storage: $e');
    }
  }

  // Job card with modern design
  Widget _buildJobCard(Job job, BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToApplication(context, job),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header with title and badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      job.type ?? 'غير محدد',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1, thickness: 1),

            // Job details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employer info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        job.userName ?? 'صاحب العمل',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Location row
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Location
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  job.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical divider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: VerticalDivider(
                            color: Colors.grey[300],
                            thickness: 1,
                            width: 1,
                          ),
                        ),

                        // Salary
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${job.salary} جنيه',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom row with date and apply button
                  Row(
                    children: [
                      // Posted date
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              job.createdAt != null
                                  ? 'منذ ${DateTime.now().difference(job.createdAt!).inDays} أيام'
                                  : 'تاريخ غير متوفر',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Apply button
                      ElevatedButton.icon(
                        onPressed: () => _navigateToApplication(context, job),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('تقديم الآن'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to application page
  void _navigateToApplication(BuildContext context, Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ApplicationPage(
              job: {
                'id': job.id,
                'title': job.title,
                'company': job.userName ?? 'صاحب العمل',
                'location': job.location,
                'salary': '${job.salary} جنيه',
                'type': job.type ?? 'غير محدد',
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً، ${widget.userName}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WorkerProfilePage(
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                        userJob: widget.userJob,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'البحث عن وظائف...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),

          // Jobs list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadJobs,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Consumer<JobProvider>(
                        builder: (context, jobProvider, child) {
                          if (jobProvider.error != null) {
                            return _buildErrorState(jobProvider.error!);
                          } else if (jobProvider.jobs.isEmpty) {
                            return _buildEmptyState();
                          } else {
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: jobProvider.jobs.length,
                              itemBuilder: (context, index) {
                                return _buildJobCard(
                                  jobProvider.jobs[index],
                                  context,
                                );
                              },
                            );
                          }
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadJobs,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 70, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل الوظائف',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadJobs,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_off_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'لا توجد وظائف متاحة حالياً',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'حاول مرة أخرى لاحقاً أو قم بتحديث الصفحة للتحقق من وجود وظائف جديدة',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadJobs,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }
}
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('الإعدادات'),
//         backgroundColor: Colors.orange,
//       ),
//       body: Center(
//         child: Text('صفحة الإعدادات'),
//       ),
//     );
//   }
// }
