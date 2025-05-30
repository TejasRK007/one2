import 'package:flutter/material.dart';
import 'home_screen.dart'; // Adjust the import path as needed

class PaymentSuccessPage extends StatelessWidget {
  final double amount;
  final String username;
  final String email;
  final String phone;
  final String password;

  const PaymentSuccessPage({
    Key? key,
    required this.amount,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Payment of ₹$amount was successful!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(
                      username: username,
                      email: email,
                      phone: phone,
                      password: password,
                    ),
                  ),
                      (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
