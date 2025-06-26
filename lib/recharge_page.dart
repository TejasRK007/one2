import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/upi_pin_dialog.dart';
import 'payment_success_page.dart';

class RechargePage extends StatefulWidget {
  final String phone, username, email, password;
  final String? upiPin;
  final void Function(String)? onPinSet;

  const RechargePage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
    this.upiPin,
    this.onPinSet,
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
    final pinVerified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => UpiPinDialog(
        currentPin: widget.upiPin,
        onPinVerified: (_) async {
          try {
            final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
            final balanceRef = ref.child('balance');
            final snapshot = await balanceRef.get();
            double current = snapshot.exists ? double.tryParse(snapshot.value.toString()) ?? 0.0 : 0.0;
            final updated = current + enteredAmount;
            await balanceRef.set(updated);
            // Increment reward points and log history
            final rewardPointsSnapshot = await ref.child('rewardPoints').get();
            final currentPoints = rewardPointsSnapshot.exists ? int.tryParse(rewardPointsSnapshot.value.toString()) ?? 0 : 0;
            final newPoints = currentPoints + 1;
            await ref.update({'rewardPoints': newPoints});
            await ref.child('rewardHistory').push().set({
              'points': 1,
              'timestamp': DateTime.now().toString(),
              'description': 'Earned for Wallet Recharge',
            });
            await ref.child('transactions').push().set({
              'amount': enteredAmount,
              'timestamp': DateTime.now().toString(),
              'purpose': 'Wallet Recharge',
            });
            // Add notification
            await ref.child('notifications').push().set({
              'title': 'Wallet Recharged',
              'body': 'You recharged your wallet with ₹${enteredAmount.toStringAsFixed(2)}. 1 reward point awarded.',
              'timestamp': DateTime.now().toString(),
              'read': false,
            });
            Navigator.of(dialogContext).pop(true);
          } catch (e) {
            setState(() => message = 'Recharge failed: $e');
            Navigator.of(dialogContext).pop(false);
          }
        },
        onPinSet: widget.onPinSet,
      ),
    );
    if (pinVerified == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            amount: enteredAmount,
            recipient: 'Wallet Recharge',
            username: widget.username,
            email: widget.email,
            phone: widget.phone,
            password: widget.password,
          ),
        ),
      );
    } else {
      setState(() => message = message.isNotEmpty ? message : 'Recharge failed. Please try again.');
    }
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
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
