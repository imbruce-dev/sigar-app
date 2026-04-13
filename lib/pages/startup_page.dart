import 'package:flutter/material.dart';
import 'dart:async';

class StartupPage extends StatefulWidget {
  const StartupPage({Key? key}) : super(key: key);

  @override
  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home page after a delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF013781), // Blue background
      body: Center(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(seconds: 2),
          child: Image.asset(
            'lib/assets/images/logo-whitesigar.png', // Path to the white logo
            width: 150, // Adjust size if needed
            height: 150, // Adjust size if needed
          ),
        ),
      ),
    );
  }
}


class _StartupPageState extends State<StartupPage> {
  Widget build(BuildContext BuildContext)





}