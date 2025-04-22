import 'package:flutter/material.dart';

class PostedProfile extends StatelessWidget {
  // بيانات المشاريع المنشورة
  final List<Map<String, String>> postedProjects = const [
    {'title': 'مشروع تصميم تطبيق', 'status': 'جاري التنفيذ', 'projectId': '1'},
    {'title': 'مطلوب نجار', 'status': 'في انتظار الموافقة', 'projectId': '2'},
    {'title': 'تركيب كاميرات مراقبة', 'status': 'منتهي', 'projectId': '3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مشاريعي المنشورة'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Text(
              'عرض جميع المشاريع المنشورة:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // قائمة المشاريع المنشورة
            Expanded(
              child: ListView.builder(
                itemCount: postedProjects.length,
                itemBuilder: (context, index) {
                  final project = postedProjects[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(project['title']!),
                      subtitle: Text('الحالة: ${project['status']}'),
                      leading: Icon(Icons.work),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: () {
                              // زر عرض التفاصيل
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailPage(
                                    projectId: project['projectId']!,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // زر تعديل المشروع
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProjectPage(
                                    projectId: project['projectId']!,
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
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectDetailPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailPage({required this.projectId});

  @override
  Widget build(BuildContext context) {
    // عرض تفاصيل المشروع
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المشروع'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل المشروع $projectId',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // يمكن إضافة المزيد من التفاصيل هنا
            Text('وصف المشروع هنا...', style: TextStyle(fontSize: 18)),
            // قد تشمل تفاصيل إضافية مثل المدة، المتطلبات، إلخ.
          ],
        ),
      ),
    );
  }
}

class EditProjectPage extends StatelessWidget {
  final String projectId;

  const EditProjectPage({required this.projectId});

  @override
  Widget build(BuildContext context) {
    // صفحة تعديل المشروع
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل المشروع'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعديل تفاصيل المشروع $projectId',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // إضافة حقول لتعديل المشروع
            TextField(
              decoration: InputDecoration(labelText: 'عنوان المشروع'),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'وصف المشروع'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // حفظ التعديلات
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حفظ التعديلات بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('حفظ التعديلات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
