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

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref().child('users/$phone/balance');
    return Scaffold(
      appBar: AppBar(title: const Text('Your Balance')),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading balance'));
          } else {
            final value = snapshot.data?.snapshot.value;
            final balance = value != null ? double.tryParse(value.toString()) ?? 0.0 : 0.0;
            return Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 48, color: Colors.indigo),
                      const SizedBox(height: 18),
                      Text(
                        'Hello, $username',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.indigo),
                      ),
                      const SizedBox(height: 10),
                      const Text('Current Balance', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text(
                        '₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
