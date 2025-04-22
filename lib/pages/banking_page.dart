import 'package:flutter/material.dart';

class BankingPage extends StatelessWidget {
  const BankingPage({super.key});

  void _askPin(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        final pinController = TextEditingController();

        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            controller: pinController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter 4-digit PIN'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text("Submit"),
              onPressed: () {
                Navigator.pop(context);
                _showBankDetails(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showBankDetails(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Bank Account Details'),
            content: const Text(
              "Balance: ₹12,000\nAccount No: 1234567890\nBranch: India Main",
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
