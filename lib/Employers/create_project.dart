import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'employer_profile.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Image Handling
  XFile? _selectedImage;

  // Project Data
  List<Map<String, dynamic>> _projects = [];
  String _jobType = 'دوام كامل'; // Default job type

  final TextEditingController salaryController = TextEditingController();

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
  void _submitProject() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _projects.add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'workers': int.parse(_workersController.text),
          'status': 'في انتظار الموافقة',
          'image': _selectedImage?.path,
          'date': DateTime.now().toString(),
        });
      });

      _saveProjects();
      Navigator.pop(context);
      _clearForm();
    }
  }

  // Clear form fields
  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _workersController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
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
    return UserAccountsDrawerHeader(
      accountName: Text(widget.userName),
      accountEmail: const Text('employer@email.com'),
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
                          userName: widget.userName,
                          userEmail: 'employer@email.com',
                          companyName: 'اسم الشركة',
                        ),
                  ),
                ),
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            text: 'الإعدادات',
            onTap: () => Navigator.pushNamed(context, '/settings'),
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
          items: ['دوام كامل', 'دوام جزئي']
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
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
          final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (image != null) {
            setState(() => _selectedImage = image);
          } else {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لم يتم اختيار صورة')),
            );
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
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
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
    return const Text(
      'مشاريعي المنشورة:',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Text('الحالة: ${project['status']}'),
              ],
            ),
          ],
        ),
        trailing: Text('${project['workers']} عامل'),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'جاري التنفيذ':
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
  }


