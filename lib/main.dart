import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const OneCardOneNationApp());
}

class OneCardOneNationApp extends StatelessWidget {
  const OneCardOneNationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Card One Nation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF050238)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
