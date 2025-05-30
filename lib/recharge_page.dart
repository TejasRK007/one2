import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RechargePage extends StatefulWidget {
  final String phone, username, email, password;

  const RechargePage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final TextEditingController _controller = TextEditingController();
  String message = '';

  Future<void> rechargeBalance() async {
    final enteredAmount = double.tryParse(_controller.text.trim());
    if (enteredAmount == null || enteredAmount <= 0) {
      setState(() => message = 'Enter a valid amount');
      return;
    }

    final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}/balance');
    final snapshot = await ref.get();
    double current = snapshot.exists ? double.tryParse(snapshot.value.toString()) ?? 0.0 : 0.0;
    final updated = current + enteredAmount;

    await ref.set(updated);
    setState(() => message = 'Recharged successfully! New Balance: ₹${updated.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recharge Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter recharge amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: rechargeBalance,
              child: const Text('Recharge'),
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
