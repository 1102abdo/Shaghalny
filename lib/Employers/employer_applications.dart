import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/application_provider.dart';
import 'package:shaghalny/models/application_model.dart';
import 'package:shaghalny/services/api_service.dart';

class EmployerApplications extends StatefulWidget {
  final int jobId;

  const EmployerApplications({super.key, required this.jobId});

  @override
  State<EmployerApplications> createState() => _EmployerApplicationsState();
}

class _EmployerApplicationsState extends State<EmployerApplications> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Enable mock API mode to ensure applications can be seen
    _enableMockApiIfNeeded();
    _loadApplications(forceRefresh: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload applications when the screen is displayed
    _refreshApplicationsIfNeeded();
  }

  // Enable mock API mode if we're having connection issues
  Future<void> _enableMockApiIfNeeded() async {
    try {
      final status = await ApiService.checkApiStatus();
      if (status['status'] != 'online') {
        print('Employer applications: API is not online, enabling mock mode');
        ApiService.setMockApiMode(true);
      }
    } catch (e) {
      print('Employer applications: Error checking API status: $e');
      // Enable mock mode on error
      ApiService.setMockApiMode(true);
    }
    print(
      'Employer applications: Mock API mode is ${ApiService.isMockApiEnabled() ? 'enabled' : 'disabled'}',
    );
  }

  Future<void> _refreshApplicationsIfNeeded() async {
    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );

    // Load applications if empty or if we have an error
    if (applicationProvider.applications.isEmpty ||
        applicationProvider.error != null) {
      print(
        'EmployerApplications: No applications or error, loading applications for job ${widget.jobId}',
      );
      await _loadApplications(forceRefresh: true);
    } else {
      print(
        'EmployerApplications: ${applicationProvider.applications.length} applications already loaded',
      );
      // If we already have applications but are looking at a specific job, verify they're for this job
      if (widget.jobId != 0 && applicationProvider.applications.isNotEmpty) {
        // Check if applications are for this specific job
        bool hasCorrectJobApplications = applicationProvider.applications.any(
          (app) => app.jobsId == widget.jobId,
        );

        if (!hasCorrectJobApplications) {
          print(
            'EmployerApplications: Applications exist but not for job ${widget.jobId}, reloading',
          );
          await _loadApplications(forceRefresh: true);
        }
      }
    }
  }

  Future<void> _loadApplications({bool forceRefresh = false}) async {
    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );
    setState(() => _isLoading = true);

    try {
      print(
        'EmployerApplications: Loading applications for job ${widget.jobId}',
      );

      // Always fetch applications fresh from storage first to ensure we have the latest
      await applicationProvider.initializeCache();

      // Use different approach for "all applications" vs specific job
      if (widget.jobId == 0) {
        // Just re-initialize the cache to load all applications
        print('EmployerApplications: Loading all applications from cache');
      } else {
        // Load applications for a specific job
        print(
          'EmployerApplications: Loading applications for specific job ${widget.jobId}',
        );
        await applicationProvider.fetchJobApplications(widget.jobId.toString());
      }

      print(
        'EmployerApplications: ${applicationProvider.applications.length} applications loaded',
      );
    } catch (e) {
      print('EmployerApplications: Error loading applications: $e');
      // Error is already stored in the provider
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateApplicationStatus(
    Application application,
    String newStatus,
  ) async {
    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );

    setState(() => _isLoading = true);
    try {
      final success = await applicationProvider.updateApplicationStatus(
        application.id.toString(),
        newStatus,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث حالة الطلب إلى ${_getStatusText(newStatus)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث حالة الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات المقدمة'),
        backgroundColor: Colors.orange,
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                  : Consumer<ApplicationProvider>(
                    builder: (context, applicationProvider, child) {
                      if (applicationProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(applicationProvider.error!),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadApplications,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      } else if (applicationProvider.applications.isEmpty) {
                        return const Center(
                          child: Text('لا توجد طلبات مقدمة لهذه الوظيفة'),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: applicationProvider.applications.length,
                          itemBuilder: (context, index) {
                            final application =
                                applicationProvider.applications[index];
                            return _buildApplicationCard(application);
                          },
                        );
                      }
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Application application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    application.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      application.status,
                    ).withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(application.status),
                    ),
                  ),
                  child: Text(
                    _getStatusText(application.status),
                    style: TextStyle(
                      color: _getStatusColor(application.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('البريد الإلكتروني: ${application.email}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('الهاتف: ${application.phone}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.work_history, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('الخبرة: ${application.experience}'),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'المهارات:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(application.skills),
            const SizedBox(height: 16),

            // Action buttons for employers
            if (application.status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        () => _updateApplicationStatus(application, 'approved'),
                    icon: const Icon(Icons.check),
                    label: const Text('قبول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        () => _updateApplicationStatus(application, 'rejected'),
                    icon: const Icon(Icons.close),
                    label: const Text('رفض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),

            if (application.status == 'approved')
              ElevatedButton.icon(
                onPressed:
                    () => _updateApplicationStatus(application, 'completed'),
                icon: const Icon(Icons.task_alt),
                label: const Text('تم إكمال العمل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),

            if (application.createdAt != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'تم التقديم: ${_formatDate(application.createdAt!)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
