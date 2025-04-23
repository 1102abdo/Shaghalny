import 'package:flutter/material.dart';
import 'employer_profile.dart'; // الملف الشخصي لصاحب العمل
import 'setting_pages.dart';  // صفحة الإعدادات

class CreateProject extends StatefulWidget {
  final String userName;

  const CreateProject({required this.userName, super.key});

  @override
  CreateProjectState createState() => CreateProjectState();
}

class CreateProjectState extends State<CreateProject> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController workersCountController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool _hasImage = false;  // لمعرفة إذا تم إضافة صورة أم لا
  String? _imagePath;  // مسار الصورة إذا تم اختيار صورة

  List<Map<String, String>> postedProjects = [
    {'title': 'مشروع تصميم تطبيق', 'status': 'جاري التنفيذ'},
    {'title': 'مطلوب نجار', 'status': 'في انتظار الموافقة'},
    {'title': 'تركيب كاميرات مراقبة', 'status': 'منتهي'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً، ${widget.userName}'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.business, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text('صاحب عمل', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployerProfile(
                      userName: widget.userName,
                      userEmail: 'employer@email.com',
                      companyName: 'اسم الشركة',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('الإعدادات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPages()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('تسجيل الخروج'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context); // يرجع لصفحة تسجيل الدخول
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // فتح نموذج إضافة مشروع جديد
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('إضافة مشروع جديد'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            // حقل اسم المشروع
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'عنوان المشروع',
                                prefixIcon: Icon(Icons.title),
                              ),
                            ),
                            SizedBox(height: 12),
                            // حقل وصف المشروع
                            TextField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: 'وصف المشروع',
                                prefixIcon: Icon(Icons.description),
                              ),
                            ),
                            SizedBox(height: 12),
                            // حقل عدد العمال المطلوبين
                            TextField(
                              controller: workersCountController,
                              decoration: InputDecoration(
                                labelText: 'عدد العمال المطلوبين',
                                prefixIcon: Icon(Icons.people),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 12),
                            // إضافة صورة للمشروع
                            GestureDetector(
                              onTap: () {
                                // هنا يمكن استخدام مكتبة لاختيار صورة من المعرض أو الكاميرا
                                setState(() {
                                  _hasImage = true;
                                  _imagePath = 'path/to/selected/image'; // مثال فقط
                                });
                              },
                              child: _hasImage
                                  ? Image.asset(
                                      _imagePath!, 
                                      width: 100, 
                                      height: 100, 
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      width: 100,
                                      height: 100,
                                      child: Icon(Icons.add_a_photo),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            // إضافة المشروع
                            setState(() {
                              postedProjects.add({
                                'title': titleController.text,
                                'status': 'جاري التنفيذ',
                              });
                            });
                            Navigator.pop(context);
                            // إعادة تعيين الحقول
                            titleController.clear();
                            descriptionController.clear();
                            workersCountController.clear();
                          },
                          child: Text('إضافة المشروع'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.add),
              label: Text('إضافة مشروع جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'مشاريعي المنشورة:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: postedProjects.length,
                itemBuilder: (context, index) {
                  final project = postedProjects[index];
                  return Card(
                    child: ListTile(
                      title: Text(project['title']!),
                      subtitle: Text('الحالة: ${project['status']}'),
                      leading: Icon(Icons.work),
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
