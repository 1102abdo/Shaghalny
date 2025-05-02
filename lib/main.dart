import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaghalny/providers/auth_provider.dart';
import 'package:shaghalny/providers/job_provider.dart';
import 'Screens/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: const ShaghalnyApp(),
    ),
  );
}

class ShaghalnyApp extends StatelessWidget {
  const ShaghalnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shaghalny',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // You can add logic here to show different screens based on auth status
          // For now, we'll just show the welcome screen
          return WelcomeScreen();
        },
      ),
    );
  }
}
