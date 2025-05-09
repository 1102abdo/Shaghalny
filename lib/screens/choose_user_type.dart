import 'package:flutter/material.dart';
import 'login_worker_screen.dart';
import '../Employers/login_employers.dart';

class ChooseUserTypeScreen extends StatelessWidget {
  const ChooseUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'اختر نوع المستخدم',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'حدد إذا كنت عامل أو صاحب شغل لبدء استخدام التطبيق',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),

                // User type cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        // Worker card
                        Expanded(
                          child: _buildUserTypeCard(
                            context,
                            title: 'عامل',
                            icon: Icons.handyman_outlined,
                            description:
                                'ابحث عن فرص عمل وتقدم للوظائف المتاحة',
                            isWorker: true,
                            onTap:
                                () => _navigateToLogin(context, isWorker: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Employer card
                        Expanded(
                          child: _buildUserTypeCard(
                            context,
                            title: 'صاحب شغل',
                            icon: Icons.business_outlined,
                            description:
                                'أنشر وظائف جديدة وابحث عن عمال مناسبين',
                            isWorker: false,
                            onTap:
                                () =>
                                    _navigateToLogin(context, isWorker: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom tip
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'يمكنك استخدام التطبيق كعامل وصاحب شغل بنفس الحساب',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, {required bool isWorker}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                isWorker
                    ? LoginWorkerScreen(userType: 'عامل')
                    : LoginEmployers(userType: 'صاحب شغل'),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required bool isWorker,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color:
                    isWorker
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 35,
                color:
                    isWorker
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button
            Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isWorker
                          ? [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ]
                          : [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withOpacity(0.8),
                          ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isWorker
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'اختيار',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
