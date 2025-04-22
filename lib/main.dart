import 'package:flutter/material.dart';
import 'Screens/WelcomeScreen.dart';

void main() {
  runApp(ShaghalnyApp());
}

class ShaghalnyApp extends StatelessWidget {
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
