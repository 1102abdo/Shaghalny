import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PostedProfile extends StatefulWidget {
  const PostedProfile({super.key});

  @override
  State<PostedProfile> createState() => _PostedProfileState();
}

class _PostedProfileState extends State<PostedProfile> {
  // Project data
  List<Map<String, String>> postedProjects = [
    {
      'title': 'مشروع تصميم تطبيق',
      'status': 'جاري التنفيذ',
      'projectId': '1',
      'budget': '5000 جنيه',
      'location': 'القاهرة',
      'description': 'تصميم تطبيق جوال حديث وأنيق'
    },
    {
      'title': 'مطلوب نجار',
      'status': 'في انتظار الموافقة',
      'projectId': '2',
      'budget': '3000 جنيه',
      'location': 'الإسكندرية',
      'description': 'مطلوب نجار محترف لتنفيذ أعمال خشبية'
    },
    {
      'title': 'تركيب كاميرات مراقبة',
      'status': 'منتهي',
      'projectId': '3',
      'budget': '8000 جنيه',
      'location': 'الجيزة',
      'description': 'تركيب نظام مراقبة كامل'
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جاري التنفيذ':
        return Colors.orange;
      case 'في انتظار الموافقة':
        return Colors.blue;
      case 'منتهي':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المشروع'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المشروع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                postedProjects.removeWhere(
                    (project) => project['projectId'] == projectId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المشروع بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
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
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: postedProjects.length,
                itemBuilder: (context, index) {
                  final project = postedProjects[index];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project['title']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project['status']!)
                                      .withAlpha((0.2 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(project['status']!),
                                  ),
                                ),
                                child: Text(
                                  project['status']!,
                                  style: TextStyle(
                                    color: _getStatusColor(project['status']!),
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
                              Text('الميزانية: ${project['budget']}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18),
                              const SizedBox(width: 8),
                              Text('الموقع: ${project['location']}'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'الوصف: ${project['description']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
  icon: const Icon(Icons.edit, color: Colors.orange),
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProjectPage(
          projectId: project['projectId']!,
          initialTitle: project['title']!,
          initialDescription: project['description']!,
          initialBudget: project['budget']!,
          initialLocation: project['location']!,
        ),
      ),
    );

    if (result is Map<String, String>) {
      setState(() {
        // Update local data
        postedProjects[index]['title'] = result['title']!;
        postedProjects[index]['description'] = result['description']!;
        postedProjects[index]['budget'] = result['budget']!;
        postedProjects[index]['location'] = result['location']!;
      });
    }
  },
),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _showDeleteDialog(project['projectId']!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descController = TextEditingController(text: widget.initialDescription);
    _budgetController = TextEditingController(text: widget.initialBudget);
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المشروع'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان المشروع',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك أدخل عنوان المشروع';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف المشروع',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك أدخل وصف المشروع';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'الميزانية',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'الموقع',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('من فضلك املأ جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

bool success = await ApiService.updateProject(
  projectId: widget.projectId,
  title: _titleController.text,
  description: _descController.text,
  budget: _budgetController.text,
  location: _locationController.text,
);

if (success) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التعديلات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true); // Return success signal
  }
} else {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فشل في حفظ التعديلات، حاول مرة أخرى'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}