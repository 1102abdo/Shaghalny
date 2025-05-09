import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'employer_profile.dart';
import 'setting_pages.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/job_provider.dart';
import 'package:shaghalny/services/api_service.dart';
import 'package:shaghalny/providers/auth_provider.dart';

class CreateProject extends StatefulWidget {
  final String userName;
  const CreateProject({required this.userName, super.key});

  @override
  CreateProjectState createState() => CreateProjectState();
}

class CreateProjectState extends State<CreateProject> {
  // Controllers and Form Key
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Image Handling
  File? _selectedImage;

  // Project Data
  List<Map<String, dynamic>> _projects = [];
  String _jobType = 'دوام كامل'; // Default job type

  // Debug mode counter
  int _failedAttempts = 0;
  bool _showDebugMode = false;

  final TextEditingController salaryController = TextEditingController();

  // ignore: non_constant_identifier_names
  get SharedPreferences => null;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // Load saved projects
  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('projects');
    if (data != null) {
      setState(() {
        _projects = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  // Save projects
  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('projects', jsonEncode(_projects));
  }

  // Image Picker

  // Submit Form
  void _submitProject() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the JobProvider
        final jobProvider = Provider.of<JobProvider>(context, listen: false);

        // Check authentication first
        final isAuthenticated = await ApiService.ensureAuthenticated();
        if (!isAuthenticated) {
          // Show authentication error and offer to redirect to login
          _showAuthenticationErrorDialog();
          return;
        }

        // Validate and parse the salary
        double salary;
        try {
          // Clean the salary input (remove non-numeric characters except decimal)
          String cleanSalary = salaryController.text.trim().replaceAll(
            RegExp(r'[^\d.]'),
            '',
          );
          if (cleanSalary.isEmpty) {
            // Show specific error for empty salary
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('الرجاء إدخال قيمة صحيحة للراتب'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          salary = double.parse(cleanSalary);
          if (salary < 0) {
            // Show specific error for negative salary
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('يجب أن يكون الراتب قيمة موجبة'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } catch (e) {
          // Show detailed error when salary parsing fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تنسيق الراتب: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جاري إنشاء المشروع...'),
            duration: Duration(seconds: 1),
          ),
        );

        // Prepare job data for debugging purposes
        final jobData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'salary': salary.toString(),
          'location': _addressController.text.trim(),
          'type': _jobType,
          'numWorkers': int.tryParse(_workersController.text.trim()) ?? 1,
        };

        print('Creating job with data: $jobData');

        // Create the job using the API
        final success = await jobProvider.createJob(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          salary: salary,
          location: _addressController.text.trim(),
          type: _jobType,
          numWorkers: int.tryParse(_workersController.text.trim()) ?? 1,
        );

        if (success) {
          // Reset failed attempts counter
          _failedAttempts = 0;
          setState(() => _showDebugMode = false);

          // Clear the form
          _clearForm();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء المشروع بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Return to the previous screen with success
          Navigator.pop(context, true);
        } else {
          // Increment failed attempts counter
          _failedAttempts++;
          if (_failedAttempts >= 2) {
            setState(() => _showDebugMode = true);
          }

          // Handle specific error messages
          String errorMessage = jobProvider.error ?? "خطأ غير معروف";

          if (errorMessage.contains('Authentication token missing') ||
              errorMessage.contains('token') ||
              errorMessage.contains('log in again')) {
            // Authentication issue - show login dialog
            _showAuthenticationErrorDialog();
            return;
          } else if (errorMessage.contains('Unknown error') ||
              errorMessage.contains('500')) {
            // Server error - suggest what might be wrong
            errorMessage =
                'خطأ في الاتصال بالخادم. تأكد من الاتصال بالإنترنت وأن الخادم يعمل بشكل صحيح';

            // Try direct API call to verify token and connection
            try {
              final token = await ApiService.getToken();
              if (token == null || token.isEmpty) {
                errorMessage =
                    'لم يتم تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى';
                _showAuthenticationErrorDialog();
                return;
              }
            } catch (e) {
              print('Error checking token: $e');
            }
          }

          // Show error with specific error message from provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إنشاء المشروع: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle any exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show authentication error dialog with option to go to login screen
  void _showAuthenticationErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('خطأ في تسجيل الدخول'),
            content: const Text(
              'انتهت صلاحية جلسة تسجيل الدخول الخاصة بك أو لم يتم تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى للمتابعة.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري التحقق من الاتصال...'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Try to validate the existing token
                  final isAuthenticated =
                      await ApiService.ensureAuthenticated();
                  if (isAuthenticated) {
                    // Token is still valid, try submitting again
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم التحقق من تسجيل الدخول، جاري المحاولة مرة أخرى...',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    _submitProject();
                  } else {
                    // Still not authenticated, show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'فشل التحقق من تسجيل الدخول، يرجى تسجيل الدخول مرة أخرى',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('إعادة المحاولة'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Close dialog and navigate to login screen
                  Navigator.of(context).pop();
                  // Navigate to the login screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/', // Go to welcome/login screen
                    (route) => false, // Remove all previous routes
                  );
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
    );
  }

  // Clear form fields
  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _workersController.clear();
    _addressController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectDialog(),
        backgroundColor: Colors.orange,
        tooltip: 'إضافة مشروع جديد',
        child: const Icon(Icons.add),
      ),
    );
  }

  // App Bar
  AppBar _buildAppBar() {
    return AppBar(
      title: Text('أهلاً، ${widget.userName}'),
      backgroundColor: Colors.orange,
      elevation: 2,
    );
  }

  // Drawer Header
  Widget _buildDrawerHeader() {
    // Get user data from the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return UserAccountsDrawerHeader(
      accountName: Text(user?.name ?? widget.userName),
      accountEmail: Text(user?.email ?? 'employer@email.com'),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 40, color: Colors.orange),
      ),
      decoration: const BoxDecoration(color: Colors.orange),
    );
  }

  // Drawer Item Builder
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(text),
      onTap: onTap,
    );
  }

  // Navigation Drawer
  Widget _buildDrawer() {
    // Get user data from the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.person,
            text: 'الملف الشخصي',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EmployerProfile(
                          userName: user?.name ?? widget.userName,
                          userEmail: user?.email ?? 'employer@email.com',
                          companyName: user?.company ?? 'اسم الشركة',
                        ),
                  ),
                ),
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            text: 'الإعدادات',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPages()),
                ),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'تسجيل الخروج',
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  // Body Content
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddButton(),
          const SizedBox(height: 24),
          _buildProjectListHeader(),
          const SizedBox(height: 12),
          _buildProjectList(_projects),
        ],
      ),
    );
  }

  // Add Project Button
  Widget _buildAddButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_circle),
      label: const Text('إضافة مشروع جديد'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      ),
      onPressed: () => _showProjectDialog(),
    );
  }

  // Project Dialog
  void _showProjectDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Center(child: Text('إضافة مشروع جديد')),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 15),
                    _buildDescriptionField(),
                    const SizedBox(height: 15),
                    _buildWorkersField(),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان *',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'يرجى إدخال العنوان' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildImageUpload(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: _submitProject,
                child: const Text('حفظ المشروع'),
              ),
            ],
          ),
    );
  }

  // Form Fields
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'عنوان المشروع *',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'يرجى إدخال العنوان' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'وصف المشروع *',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'يرجى إدخال الوصف' : null,
    );
  }

  Widget _buildWorkersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _workersController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'عدد العمال المطلوبين *',
            prefixIcon: Icon(Icons.people),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'يرجى إدخال العدد';
            if (int.tryParse(value) == null) return 'يجب أن يكون رقمًا صحيحًا';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: salaryController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'الراتب الشهري (ج.م) *',
            prefixIcon: Icon(Icons.attach_money),
            suffixText: 'ج.م',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'يرجى إدخال الراتب';
            if (double.tryParse(value) == null) return 'يجب أن يكون رقمًا';
            return null;
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _jobType,
          items:
              ['دوام كامل', 'دوام جزئي']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: (value) {
            setState(() => _jobType = value!);
          },
          decoration: const InputDecoration(
            labelText: 'نوع الوظيفة *',
            prefixIcon: Icon(Icons.schedule),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: () async {
        try {
          final File? image =
              (await ImagePicker().pickImage(source: ImageSource.gallery))
                  as File?;
          if (image != null) {
            setState(() => _selectedImage = image);
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('لم يتم اختيار صورة')));
          }
        } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء تحميل الصورة')),
          );
        }
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            _selectedImage != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 40),
                    SizedBox(height: 8),
                    Text('إضافة صورة للمشروع'),
                  ],
                ),
      ),
    );
  }

  // Project List
  Widget _buildProjectListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'مشاريعي المنشورة:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (_showDebugMode)
          TextButton.icon(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            label: const Text(
              'وضع التصحيح',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: _showDebugDialog,
          ),
      ],
    );
  }

  Widget _buildProjectList(dynamic projects) {
    return Expanded(
      child: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) => _buildProjectItem(projects[index]),
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.work_outline, size: 30),
        title: Text(project['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project['description']),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildStatusIndicator(project['status']),
                const SizedBox(width: 8),
                Text('الحالة: ${project['status'] ?? "نشطة"}'),
              ],
            ),
          ],
        ),
        trailing: Text('${project['workers']} عامل'),
      ),
    );
  }

  Widget _buildStatusIndicator(String? status) {
    Color color;

    // Default to active status if null
    final displayStatus = status ?? 'نشطة';

    switch (displayStatus) {
      case 'جاري التنفيذ':
      case 'نشطة':
        color = Colors.green;
        break;
      case 'في انتظار الموافقة':
        color = Colors.orange;
        break;
      case 'منتهي':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('مساعدة في حل المشكلة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'هناك مشكلة في إنشاء المشروع. جرب الحلول التالية:',
                  ),
                  const SizedBox(height: 12),
                  const Text('1. تأكد من اتصالك بالإنترنت'),
                  const Text('2. تأكد من تسجيل الدخول بشكل صحيح'),
                  const Text('3. حاول تسجيل الخروج ثم تسجيل الدخول مرة أخرى'),
                  const Text('4. تحقق من إدخال بيانات صحيحة للراتب'),
                  const SizedBox(height: 16),
                  const Text(
                    'معلومات تقنية للمطورين:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                    future: ApiService.getToken(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final token = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('API URL: ${ApiService.getBaseUrl()}'),
                          Text(
                            'وجود رمز التوثيق: ${token != null && token.isNotEmpty ? "نعم" : "لا"}',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/debug');
                },
                child: const Text('فتح شاشة التصحيح'),
              ),
            ],
          ),
    );
  }
}
