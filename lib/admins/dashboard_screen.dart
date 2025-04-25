import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // قائمة وهمية للمستخدمين
  List<Map<String, String>> users = [
    {"id": "1", "name": "Ahmed", "email": "ahmed@mail.com", "role": "Worker"},
    {"id": "2", "name": "Mona", "email": "mona@mail.com", "role": "Employer"},
  ];

  // قائمة وهمية للبوستات
  List<Map<String, String>> posts = [
    {"id": "1", "title": "Job Post #1", "postedBy": "Mona"},
    {"id": "2", "title": "Job Post #2", "postedBy": "Ahmed"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF9800),  // اللون البرتقالي للأب بار
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Users'),
            Tab(text: 'Posts'),
          ],
          indicatorColor: Colors.white,  // مؤشر التبويب باللون الأبيض
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTable(),
          _buildPostsView(),
        ],
      ),
    );
  }

  // بناء جدول المستخدمين مع الأزرار لإدارة المستخدمين
  Widget _buildUsersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Actions')),
        ],
        rows: users.map((user) {
          return DataRow(cells: [
            DataCell(Text(user['id']!)),
            DataCell(Text(user['name']!)),
            DataCell(Text(user['email']!)),
            DataCell(Text(user['role']!)),
            DataCell(Row(
              children: [
                IconButton(
                  icon: Icon(Icons.visibility, color: Color(0xFFFF9800)),  // عرض البيانات
                  onPressed: () {
                    _showUserDetails(user);  // عرض بيانات المستخدم
                  },
                ),
                IconButton(
                  icon: Icon(Icons.block, color: Colors.red),  // حظر المستخدم
                  onPressed: () {
                    _blockUser(user);  // حظر المستخدم
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),  // حذف المستخدم
                  onPressed: () {
                    _deleteUser(user);  // حذف المستخدم
                  },
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // بناء شاشة عرض البوستات
  Widget _buildPostsView() {
    return ListView(
      children: posts.map((post) {
        return ListTile(
          leading: Icon(Icons.work, color: Color(0xFFFF9800)),  // اللون البرتقالي للأيقونات
          title: Text(post['title']!),
          subtitle: Text('Posted by ${post['postedBy']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Color(0xFFFF9800)),
                onPressed: () {
                  _editPost(post);  // تحرير البوست
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deletePost(post);  // حذف البوست
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // عرض بيانات المستخدم
  void _showUserDetails(Map<String, String> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${user['id']}'),
              Text('Name: ${user['name']}'),
              Text('Email: ${user['email']}'),
              Text('Role: ${user['role']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // حظر المستخدم
  void _blockUser(Map<String, String> user) {
    setState(() {
      // تغيير حالة المستخدم إلى معطل أو مفعل
      user['role'] = user['role'] == 'Worker' ? 'Blocked' : 'Worker';
    });
  }

  // حذف المستخدم
  void _deleteUser(Map<String, String> user) {
    setState(() {
      users.remove(user);  // إزالة المستخدم من القائمة
    });
  }

  // تحرير البوست
  void _editPost(Map<String, String> post) {
    // هنا يمكنك إضافة نافذة لتعديل البوست أو أي وظيفة أخرى
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: Text('Edit details of post: ${post['title']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // حذف البوست
  void _deletePost(Map<String, String> post) {
    setState(() {
      posts.remove(post);  // إزالة البوست من القائمة
    });
  }
}
