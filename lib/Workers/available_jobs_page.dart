import 'package:flutter/material.dart';
import 'package:shaghalny/Workers/application_page.dart';

class AvailableJobsPage extends StatelessWidget {
  final String userName;

  // بيانات تجريبية للوظائف
  final List<Map<String, dynamic>> jobs = [
    {
      'id': 1,
      'title': 'مطور Flutter',
      'company': 'شركة التقنية الحديثة',
      'location': 'القاهرة',
      'salary': '10,000 - 15,000 جنيه',
      'type': 'دوام كامل',
      'posted': 'منذ 3 أيام',
    },
    {
      'id': 2,
      'title': 'مصمم جرافيك',
      'company': 'استوديو الإبداع',
      'location': 'الإسكندرية',
      'salary': '8,000 - 12,000 جنيه',
      'type': 'دوام جزئي',
      'posted': 'منذ يومين',
    },
  ];

  AvailableJobsPage({required this.userName, super.key});

  // دالة لبناء بطاقة الوظيفة
  Widget _buildJobCard(Map<String, dynamic> job, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Chip(
                  label: Text(job['type'] ?? 'غير محدد'),
                  backgroundColor: Colors.orange.withAlpha((0.2 * 255).toInt()),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.business, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(job['company']),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(job['location']),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(job['salary']),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(job['posted'], style: TextStyle(color: Colors.grey)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationPage(job: job),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('تقديم الآن'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً، $userName'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return _buildJobCard(jobs[index], context);
        },
      ),
    );
  }
}