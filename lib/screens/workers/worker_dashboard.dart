import 'package:flutter/material.dart';
import 'package:shaghalny/Workers/settings_page.dart';
import 'package:shaghalny/services/api_service.dart';

// Define the Job class
class Job {
  final String title;
  final String description;

  Job({required this.title, required this.description});

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WorkerDashboardState createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  List<Job> _jobs = [];
  bool _isLoading = true;
  
  get currentUser => null;

  // ignore: unused_element
  Future<void> _loadJobs() async {
    try {
      final response = await ApiService.getJobs();
      setState(() {
        _jobs = (response as List<dynamic>)
            .map((job) => Job.fromJson(job as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load jobs: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Jobs"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => SettingsPage()),
            ),
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(currentUser),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _jobs.length,
              itemBuilder: (BuildContext context, int index) {
                final job = _jobs[index];
                return ListTile(
                  title: Text(job.title),
                  subtitle: Text(job.description),
                  onTap: () {
                    // Handle job selection
                  },
                );
              },
            ),
    );
  }

  Widget _buildNavigationDrawer(dynamic currentUser) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.name),
            accountEmail: Text(currentUser.email),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
        child: Text("This is the Profile Page"),
      ),
    );
  }
}