import 'package:flutter/material.dart';
import 'package:shaghalny/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch users
      final usersResponse = await ApiService.adminRequest(
        method: 'GET',
        endpoint: 'admin/users',
      );

      // Fetch posts
      final postsResponse = await ApiService.adminRequest(
        method: 'GET',
        endpoint: 'admin/posts',
      );

      if (usersResponse['status'] == 200 && usersResponse['data'] != null) {
        setState(() {
          users = List<Map<String, dynamic>>.from(usersResponse['data']);
        });
      }

      if (postsResponse['status'] == 200 && postsResponse['data'] != null) {
        setState(() {
          posts = List<Map<String, dynamic>>.from(postsResponse['data']);
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
        _isLoading = false;
      });
    }
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
        backgroundColor: Color(0xFFFF9800),
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Users'), Tab(text: 'Posts')],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9800)),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF9800),
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [_buildUsersTable(), _buildPostsView()],
              ),
    );
  }

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
        rows:
            users.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user['id'].toString())),
                  DataCell(Text(user['name'] ?? '')),
                  DataCell(Text(user['email'] ?? '')),
                  DataCell(Text(user['role'] ?? 'N/A')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.visibility,
                            color: Color(0xFFFF9800),
                          ),
                          onPressed: () => _showUserDetails(user),
                        ),
                        IconButton(
                          icon: Icon(Icons.block, color: Colors.red),
                          onPressed: () => _blockUser(user),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPostsView() {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(Icons.work, color: Color(0xFFFF9800)),
            title: Text(post['title'] ?? 'Untitled Post'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posted by: ${post['user_name'] ?? 'Unknown'}'),
                Text('Status: ${post['status'] ?? 'N/A'}'),
                if (post['salary'] != null) Text('Salary: \$${post['salary']}'),
                if (post['location'] != null)
                  Text('Location: ${post['location']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFFF9800)),
                  onPressed: () => _editPost(post),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePost(post),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${user['id']}'),
              Text('Name: ${user['name']}'),
              Text('Email: ${user['email']}'),
              Text('Role: ${user['role']}'),
              Text('Company: ${user['company'] ?? 'N/A'}'),
              Text('Status: ${user['ban'] == '1' ? 'Banned' : 'Active'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _blockUser(Map<String, dynamic> user) async {
    try {
      final response = await ApiService.adminRequest(
        method: 'PUT',
        endpoint: 'admin/users/${user['id']}/toggle-ban',
      );

      if (response['status'] == 200) {
        _loadData(); // Refresh the data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['msg'] ?? 'Failed to update user status'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating user status: $e')));
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    try {
      final response = await ApiService.adminRequest(
        method: 'DELETE',
        endpoint: 'admin/users/${user['id']}',
      );

      if (response['status'] == 200) {
        _loadData(); // Refresh the data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['msg'] ?? 'Failed to delete user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
    }
  }

  void _editPost(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${post['title']}'),
              Text('Description: ${post['description'] ?? 'N/A'}'),
              Text('Status: ${post['status']}'),
              Text('Salary: \$${post['salary'] ?? 'N/A'}'),
              Text('Location: ${post['location'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(Map<String, dynamic> post) async {
    try {
      final response = await ApiService.adminRequest(
        method: 'DELETE',
        endpoint: 'admin/posts/${post['id']}',
      );

      if (response['status'] == 200) {
        setState(() {
          posts.removeWhere((p) => p['id'] == post['id']);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['msg'] ?? 'Failed to delete post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
    }
  }
}
