import 'package:flutter/material.dart';

class EmployerApplications extends StatelessWidget {
  final List<Map<String, dynamic>> applications = [
    {
      'name': 'محمد سعيد',
      'email': 'moahmedsaied@gmnck.com',
      'phone': '0123456789',
      'status': 'معلق'
    },
  ];

  EmployerApplications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الطلبات المقدمة'),
        backgroundColor: Colors.orange,
      ),
      body: applications.isEmpty
          ? Center(child: Text('لا توجد طلبات مقدمة حالياً'))
          : ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(application['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(application['email']),
                        Text(application['phone']),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(application['status']),
                      backgroundColor: _getStatusColor(application['status']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مقبول':
        return Colors.green.withAlpha((0.3 * 255).toInt());
      case 'مرفوض':
        return Colors.red.withAlpha((0.3 * 255).toInt());
      default:
        return Colors.orange.withAlpha((0.3 * 255).toInt());
    }
  }
}