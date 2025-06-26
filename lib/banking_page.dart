import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/upi_pin_dialog.dart';
import 'dart:math';

class BankingPage extends StatelessWidget {
  final String phone;
  final String username;
  final String email;
  final String password;
  final String? upiPin;
  final void Function(String)? onPinSet;

  const BankingPage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
    this.upiPin,
    this.onPinSet,
  });

  void _askPin(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => UpiPinDialog(
        currentPin: upiPin,
        onPinVerified: (_) async {
          Navigator.of(dialogContext).pop();
          final ref = FirebaseDatabase.instance.ref().child('users/$phone/balance');
          final snapshot = await ref.get();
          final balance = snapshot.exists ? double.tryParse(snapshot.value.toString()) ?? 0.0 : 0.0;
          final random = Random();
          final accountNumber = List.generate(10, (_) => random.nextInt(10)).join();
          _showBankDetails(context, balance, accountNumber);
        },
        onPinSet: onPinSet,
      ),
    );
  }

  void _showBankDetails(BuildContext context, double balance, String accountNumber) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bank Account Details'),
        content: Text(
          "Balance: ₹${balance.toStringAsFixed(2)}\nAccount No: $accountNumber\nBranch: India Main",
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Banking")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _askPin(context),
          icon: const Icon(Icons.lock),
          label: const Text("Access My Bank"),
        ),
      ),
    );
  }
}