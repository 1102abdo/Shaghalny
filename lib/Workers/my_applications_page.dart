import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/application_provider.dart';
import 'package:shaghalny/models/application_model.dart';

class MyApplicationsPage extends StatefulWidget {
  final int workerId;

  const MyApplicationsPage({super.key, required this.workerId});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );
    setState(() => _isLoading = true);
    try {
      await applicationProvider.fetchWorkerApplications(
        widget.workerId.toString(),
      );
    } catch (e) {
      // Error is already stored in the provider
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
        title: const Text('طلباتي المرسلة'),
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
                          child: Text('لم تقم بإرسال أي طلبات بعد'),
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
                    application.jobTitle ?? 'وظيفة',
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
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text('الاسم: ${application.name}'),
              ],
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            if (application.cv != null && application.cv!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('السيرة الذاتية: ${application.cv}'),
                ],
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
