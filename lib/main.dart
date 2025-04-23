import 'package:flutter/material.dart';
import 'Screens/welcome_screen.dart';

void main() {
  runApp(ShaghalnyApp());
}

class ShaghalnyApp extends StatelessWidget {
  const ShaghalnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Shaghalny',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: WelcomeScreen(), 
    );
  }
}
