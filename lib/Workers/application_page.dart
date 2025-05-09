import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/application_provider.dart';
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/Workers/my_applications_page.dart';
import 'package:shaghalny/widgets/error_handlers.dart';
import 'package:shaghalny/services/api_service.dart';

class ApplicationPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const ApplicationPage({super.key, required this.job});

  @override
  ApplicationPageState createState() => ApplicationPageState();
}

class ApplicationPageState extends State<ApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String? _cvPath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Check if we should use mock mode for better offline experience
    _checkAndEnableMockModeIfNeeded();

    // Pre-populate fields with worker info if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.worker != null) {
      _nameController.text = authProvider.worker!.name;
      _emailController.text = authProvider.worker!.email;
      _experienceController.text = '${authProvider.worker!.job} خبرة في';
    }
  }

  // Check API connection and enable mock mode if needed
  Future<void> _checkAndEnableMockModeIfNeeded() async {
    try {
      final apiStatus = await ApiService.checkApiStatus();
      if (apiStatus['status'] == 'offline' || apiStatus['status'] == 'error') {
        print('API is offline, enabling mock mode for application submission');
        ApiService.setMockApiMode(true);
      }
    } catch (e) {
      print('Error checking API status: $e');
      // Enable mock mode on any error
      ApiService.setMockApiMode(true);
    }
  }

  Future<void> _uploadCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _cvPath = result.files.single.path;
      });
    }
  }

  Future<void> _submitApplication() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = null;
    });

    // Use a try-catch block to handle widget errors
    try {
      // Validate the form first
      if (!_formKey.currentState!.validate()) {
        print('Form validation failed');

        // Collect validation errors
        Map<String, String?> formErrors = {
          'name': _nameController.text.isEmpty ? 'الاسم مطلوب' : null,
          'email':
              _emailController.text.isEmpty ? 'البريد الإلكتروني مطلوب' : null,
          'phone': _phoneController.text.isEmpty ? 'رقم الهاتف مطلوب' : null,
          'experience':
              _experienceController.text.isEmpty ? 'الخبرة مطلوبة' : null,
        };

        // Print specific form errors for debugging
        formErrors.forEach((field, error) {
          if (error != null) {
            print('Validation error in $field: $error');
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تعبئة جميع الحقول المطلوبة بشكل صحيح'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _errorMessage = 'يرجى التأكد من تعبئة جميع الحقول المطلوبة بشكل صحيح';
        });
        return;
      }

      // Make sure we have a valid job ID
      final jobId = int.tryParse(widget.job['id'].toString());
      if (jobId == null) {
        print('Invalid job ID: ${widget.job['id']}');
        setState(() {
          _errorMessage = 'معرف الوظيفة غير صالح';
        });
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if worker is logged in
      if (authProvider.worker == null) {
        print('Worker is null, user needs to log in first');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب تسجيل الدخول كعامل أولاً'),
            backgroundColor: Colors.red,
          ),
        );

        // Use the error handler to show a proper dialog
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('تسجيل الدخول مطلوب'),
                  content: Text(
                    'يجب تسجيل الدخول لإرسال طلب التوظيف. هل تريد تسجيل الدخول الآن؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to login page (you need to implement this)
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: Text('تسجيل الدخول'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('إلغاء'),
                    ),
                  ],
                ),
          );
        }
        return;
      }

      // Make sure worker has a valid ID
      final workerId = authProvider.worker!.id;
      if (workerId == null) {
        print('Worker ID is null');

        // Log more details about the worker object
        print('Worker details: ${authProvider.worker?.toJson()}');

        if (!mounted) return;

        setState(() {
          _errorMessage =
              'معرف العامل غير صالح، يرجى تسجيل الخروج وإعادة تسجيل الدخول';
        });

        // Use the specialized error handler for Worker ID null error
        if (mounted) {
          showWorkerIdNullErrorDialog(context);
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        print('Submitting application for job $jobId by worker $workerId');
        print('Name: ${_nameController.text}');
        print('Email: ${_emailController.text}');

        final applicationProvider = Provider.of<ApplicationProvider>(
          context,
          listen: false,
        );

        final success = await applicationProvider.createApplication(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          experience: _experienceController.text,
          skills: _skillsController.text,
          jobId: jobId,
          workerId: workerId,
          cv: _cvPath,
        );

        if (!mounted) return;

        if (success) {
          print('Application submitted successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال طلبك بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to My Applications page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyApplicationsPage(workerId: workerId),
            ),
          );
        } else {
          print('Application failed: ${applicationProvider.error}');
          setState(() {
            _errorMessage =
                applicationProvider.error ??
                'فشل في إرسال الطلب. حاول مرة أخرى.';
          });
        }
      } catch (e) {
        print('Exception during application submission: $e');
        if (!mounted) return;
        setState(() {
          _errorMessage = 'حدث خطأ: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle any exceptions in the widget tree
      print('Fatal error in application form: $e');
      if (mounted) {
        showWidgetErrorDialog(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('تقديم طلب وظيفة'), elevation: 1),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job details card with shadow
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job['title'],
                          style: theme.textTheme.headlineMedium,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          'الشركة:',
                          widget.job['company'],
                          Icons.business,
                        ),
                        _buildInfoRow(
                          context,
                          'الموقع:',
                          widget.job['location'],
                          Icons.location_on,
                        ),
                        _buildInfoRow(
                          context,
                          'الراتب:',
                          widget.job['salary'],
                          Icons.attach_money,
                        ),
                        _buildInfoRow(
                          context,
                          'النوع:',
                          widget.job['type'],
                          Icons.work,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Error message if present
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form title
                Text(
                  'معلومات المتقدم',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Form fields
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم بالكامل',
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'أدخل اسمك الكامل',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الاسم مطلوب';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'example@domain.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'البريد الإلكتروني مطلوب';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    hintText: '01XXXXXXXXX',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'رقم الهاتف مطلوب';
                    }
                    String cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
                    if (cleanPhone.startsWith('0')) {
                      cleanPhone = cleanPhone.substring(1);
                    }
                    if (!RegExp(r'^1[0-9]{9}$').hasMatch(cleanPhone) &&
                        !RegExp(r'^01[0-9]{9}$').hasMatch(value)) {
                      return 'يجب إدخال رقم هاتف مصري صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _experienceController,
                  decoration: InputDecoration(
                    labelText: 'الخبرة',
                    prefixIcon: const Icon(Icons.work_outline),
                    hintText: 'مثال: 3 سنوات خبرة في السباكة',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال معلومات عن خبرتك';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _skillsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'المهارات',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: const Icon(Icons.engineering_outlined),
                    ),
                    hintText: 'أدخل مهاراتك (اختياري)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // CV upload button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _uploadCV,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('رفع السيرة الذاتية (PDF)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize: const Size(double.infinity, 55),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),

                      if (_cvPath != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          color: Colors.green.withOpacity(0.1),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'تم رفع: ${_cvPath!.split('/').last}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _cvPath = null;
                                  });
                                },
                                color: Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            spreadRadius: -2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submitApplication,
                        icon: const Icon(Icons.send_outlined),
                        label: const Text(
                          'إرسال الطلب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                        ),
                      ),
                    ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
