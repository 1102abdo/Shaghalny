import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import 'package:shaghalny/Employers/employer_applications.dart';

class PostedProfile extends StatefulWidget {
  const PostedProfile({super.key});

  @override
  State<PostedProfile> createState() => _PostedProfileState();
}

class _PostedProfileState extends State<PostedProfile> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();

    // Listen for changes in the job provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      jobProvider.addListener(_onJobsChanged);
    });
  }

  @override
  void dispose() {
    // Remove the listener when disposing
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.removeListener(_onJobsChanged);
    super.dispose();
  }

  void _onJobsChanged() {
    // Refresh the UI when the jobs list changes
    if (mounted) {
      setState(() {
        // Just trigger a rebuild
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('PostedProfile: didChangeDependencies called');
    _refreshJobsIfNeeded();
  }

  Future<void> _refreshJobsIfNeeded() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (jobProvider.jobs.isEmpty || jobProvider.error != null) {
      print('PostedProfile: No jobs or error found, reloading jobs');
      await _loadJobs();
    } else {
      print('PostedProfile: ${jobProvider.jobs.length} jobs already loaded');
    }
  }

  Future<void> _loadJobs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.user != null) {
      print('Loading jobs for user ID: ${authProvider.user!.id}');
      setState(() => _isLoading = true);
      try {
        // First try to load from cache
        await jobProvider.initializeCache();

        // Then try to load from API
        await jobProvider.fetchUserJobs(authProvider.user!.id.toString());
        print('Jobs loaded: ${jobProvider.jobs.length}');
        if (jobProvider.jobs.isEmpty) {
          print('No jobs found for user. Error: ${jobProvider.error}');
        }
      } catch (e) {
        print('Error loading jobs: $e');
        setState(() => _error = e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      print('User is null, cannot load jobs');
    }
  }

  Color _getStatusColor(String? status) {
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

  void _showDeleteDialog(int jobId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف المشروع'),
            content: const Text('هل أنت متأكد من رغبتك في حذف هذا المشروع؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await ApiService.deleteJob(jobId.toString());
                    // Refresh jobs list
                    await _loadJobs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف المشروع بنجاح'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('فشل في حذف المشروع: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مشاريعي المنشورة'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobs,
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          // Navigate to create project page and refresh on return
          final result = await Navigator.pushNamed(context, '/create-project');
          if (result == true) {
            print(
              'PostedProfile: Received true result from create project page',
            );

            // Directly use the jobs from the provider
            final jobProvider = Provider.of<JobProvider>(
              context,
              listen: false,
            );
            setState(() {
              _isLoading = false;
              _error = null;
            });

            // Force refresh the list from cache
            await jobProvider.initializeCache();

            // Then try to load from API
            await _loadJobs();

            print(
              'PostedProfile: Jobs list updated with ${jobProvider.jobs.length} jobs',
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'المشاريع المنشورة:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                )
                : _error != null
                ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('حدث خطأ: $_error'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadJobs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
                : Consumer<JobProvider>(
                  builder: (context, jobProvider, child) {
                    if (jobProvider.jobs.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text('لا توجد مشاريع منشورة حتى الآن'),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.separated(
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemCount: jobProvider.jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobProvider.jobs[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          job.title,
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
                                            job.status,
                                          ).withAlpha((0.2 * 255).toInt()),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _getStatusColor(job.status),
                                          ),
                                        ),
                                        child: Text(
                                          job.status == 'pending'
                                              ? 'في انتظار الموافقة'
                                              : job.status == 'approved'
                                              ? 'تمت الموافقة'
                                              : job.status == 'rejected'
                                              ? 'مرفوض'
                                              : 'مكتمل',
                                          style: TextStyle(
                                            color: _getStatusColor(job.status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 18),
                                      const SizedBox(width: 8),
                                      Text('الميزانية: ${job.salary} جنيه'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 18),
                                      const SizedBox(width: 8),
                                      Text('الموقع: ${job.location}'),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'الوصف: ${job.description}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (job.status == 'pending')
                                        ElevatedButton(
                                          onPressed: () async {
                                            final jobProvider =
                                                Provider.of<JobProvider>(
                                                  context,
                                                  listen: false,
                                                );
                                            try {
                                              final success = await jobProvider
                                                  .updateJobStatus(
                                                    job.id.toString(),
                                                    'approved',
                                                  );
                                              if (success) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'تمت الموافقة على المشروع',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                                await _loadJobs(); // Refresh the jobs list
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'فشل في تحديث حالة المشروع: ${e.toString()}',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('موافقة'),
                                        ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => EditProjectPage(
                                                    projectId:
                                                        job.id.toString(),
                                                    initialTitle: job.title,
                                                    initialDescription:
                                                        job.description,
                                                    initialBudget:
                                                        job.salary.toString(),
                                                    initialLocation:
                                                        job.location,
                                                  ),
                                            ),
                                          );

                                          if (result == true) {
                                            // Refresh jobs if edit was successful
                                            await _loadJobs();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _showDeleteDialog(job.id),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.people),
                                    label: Text('عرض الطلبات'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EmployerApplications(
                                                jobId: job.id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class EditProjectPage extends StatefulWidget {
  final String projectId;
  final String initialTitle;
  final String initialDescription;
  final String initialBudget;
  final String initialLocation;

  const EditProjectPage({
    super.key,
    required this.projectId,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialBudget,
    required this.initialLocation,
  });

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _budgetController;
  late TextEditingController _locationController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descController = TextEditingController(text: widget.initialDescription);
    _budgetController = TextEditingController(text: widget.initialBudget);
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateProject() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await ApiService.updateProject(
        projectId: widget.projectId,
        title: _titleController.text,
        description: _descController.text,
        budget: _budgetController.text,
        location: _locationController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث المشروع بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _error = 'فشل تحديث المشروع');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المشروع'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const Text(
                        'عنوان المشروع:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'أدخل عنوان المشروع',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'وصف المشروع:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _descController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'أدخل وصف المشروع',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'الميزانية:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'أدخل ميزانية المشروع',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'الموقع:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'أدخل موقع المشروع',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'حفظ التغييرات',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
