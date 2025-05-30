import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BalancePage extends StatelessWidget {
  final String phone, username, email, password;

  const BalancePage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
  });

  Future<double> fetchBalance() async {
    final ref = FirebaseDatabase.instance.ref().child('users/$phone/balance');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return double.tryParse(snapshot.value.toString()) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Balance')),
      body: FutureBuilder<double>(
        future: fetchBalance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading balance'));
          } else {
            return Center(
              child: Text(
                '₹${snapshot.data!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          }
        },
      ),
    );
  }
}
