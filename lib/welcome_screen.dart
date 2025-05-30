import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade-in effect after frame render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate to login after delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF050238),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or splash image
              Container(
                height: screenHeight * 0.28,
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'images/1.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // App Title
              const Text(
                'One Card One Nation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Unified Digital Identity System',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 40),

              // Loading indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}