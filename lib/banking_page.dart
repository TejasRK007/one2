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
  final String? cardUID;

  const BankingPage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
    this.upiPin,
    this.onPinSet,
    this.cardUID,
  });

  void _askPin(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => UpiPinDialog(
        currentPin: upiPin,
        onPinVerified: (_) async {
          Navigator.of(dialogContext).pop();
          final ref = FirebaseDatabase.instance.ref().child('users/$phone');
          final balanceSnapshot = await ref.child('balance').get();
          final balance = balanceSnapshot.exists ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0 : 0.0;
          final emiSnapshot = await ref.child('emis').get();
          int emiCount = 0;
          String emiDetails = '';
          if (emiSnapshot.exists && emiSnapshot.value != null) {
            if (emiSnapshot.value is Map) {
              final emis = Map<String, dynamic>.from(emiSnapshot.value as Map);
              emiCount = emis.length;
              emiDetails = emis.entries.map((e) {
                final v = e.value;
                if (v is Map && v['amount'] != null && v['dueDate'] != null) {
                  return '₹${v['amount']} due on ${v['dueDate']}';
                } else if (v is Map && v['amount'] != null) {
                  return '₹${v['amount']}';
                } else if (v is String) {
                  return v;
                } else {
                  return 'EMI';
                }
              }).join('\n');
            } else if (emiSnapshot.value is List) {
              final emis = List.from(emiSnapshot.value as List);
              emiCount = emis.length;
              emiDetails = emis.map((v) {
                if (v is Map && v['amount'] != null && v['dueDate'] != null) {
                  return '₹${v['amount']} due on ${v['dueDate']}';
                } else if (v is Map && v['amount'] != null) {
                  return '₹${v['amount']}';
                } else if (v is String) {
                  return v;
                } else {
                  return 'EMI';
                }
              }).join('\n');
            }
          }
          final random = Random();
          final accountNumber = List.generate(10, (_) => random.nextInt(10)).join();
          _showBankDetails(context, balance, accountNumber, emiCount, emiDetails);
        },
        onPinSet: onPinSet,
      ),
    );
  }

  void _showBankDetails(BuildContext context, double balance, String accountNumber, int emiCount, String emiDetails) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bank Account Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account Name: $username"),
            const SizedBox(height: 8),
            Text("Account No: $accountNumber"),
            const SizedBox(height: 8),
            Text("Phone: $phone"),
            const SizedBox(height: 8),
            Text("Linked Card: " + (cardUID != null && cardUID!.isNotEmpty ? cardUID! : 'No card linked')),
            const SizedBox(height: 8),
            Text("Branch: India Main"),
            const SizedBox(height: 8),
            Text("Balance: ₹${balance.toStringAsFixed(2)}"),
            const SizedBox(height: 16),
            Text("EMIs/Instalments Pending: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(emiCount > 0 ? emiCount.toString() : '0', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (emiCount > 0) ...[
              const SizedBox(height: 8),
              Text(emiDetails),
            ] else ...[
              const SizedBox(height: 8),
              const Text("No EMIs or instalments pending."),
            ],
          ],
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