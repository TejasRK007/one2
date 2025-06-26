import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'payment_success_page.dart';
import 'widgets/upi_pin_dialog.dart';

class MobileRechargePage extends StatefulWidget {
  final String phone, username, email, password;
  final String? upiPin;
  final void Function(String)? onPinSet;
  const MobileRechargePage({super.key, required this.phone, required this.username, required this.email, required this.password, this.upiPin, this.onPinSet});

  @override
  State<MobileRechargePage> createState() => _MobileRechargePageState();
}

class _MobileRechargePageState extends State<MobileRechargePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  String? _selectedOperator;
  String message = '';
  bool isSubmitting = false;

  final List<String> operators = ['Airtel', 'Jio', 'Vi', 'BSNL'];

  Future<void> rechargeMobile() async {
    final amount = double.tryParse(_amountController.text.trim());
    final mobile = _mobileController.text.trim();
    if (amount == null || amount <= 0 || mobile.isEmpty || _selectedOperator == null) {
      setState(() => message = 'Please fill all fields correctly.');
      return;
    }
    final pinVerified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => UpiPinDialog(
        currentPin: widget.upiPin,
        onPinVerified: (_) async {
          try {
            setState(() { isSubmitting = true; message = ''; });
            final userRef = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
            final balanceSnapshot = await userRef.child('balance').get();
            final currentBalance = balanceSnapshot.exists ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0 : 0.0;
            if (currentBalance < amount) {
              setState(() { message = 'Insufficient balance.'; isSubmitting = false; });
              Navigator.of(dialogContext).pop(false);
              return;
            }
            final updatedBalance = currentBalance - amount;
            await userRef.update({'balance': updatedBalance});
            final rewardPointsSnapshot = await userRef.child('rewardPoints').get();
            final currentPoints = rewardPointsSnapshot.exists ? int.tryParse(rewardPointsSnapshot.value.toString()) ?? 0 : 0;
            final newPoints = currentPoints + 1;
            await userRef.update({'rewardPoints': newPoints});
            await userRef.child('rewardHistory').push().set({
              'points': 1,
              'timestamp': DateTime.now().toString(),
              'description': 'Earned for Mobile Recharge',
            });
            await userRef.child('transactions').push().set({
              'amount': amount,
              'timestamp': DateTime.now().toString(),
              'purpose': 'Mobile Recharge - $_selectedOperator ($mobile)',
            });
            await userRef.child('notifications').push().set({
              'title': 'Mobile Recharge Successful',
              'body': 'You recharged $mobile with ₹${amount.toStringAsFixed(2)} ($_selectedOperator). 1 reward point awarded.',
              'timestamp': DateTime.now().toString(),
              'read': false,
            });
            if (!mounted) return;
            Navigator.of(dialogContext).pop(true);
          } catch (e) {
            setState(() { message = 'Payment failed: $e'; isSubmitting = false; });
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
            amount: amount,
            recipient: _mobileController.text.trim(),
            username: widget.username,
            email: widget.email,
            phone: widget.phone,
            password: widget.password,
          ),
        ),
      );
    } else {
      setState(() {
        message = message.isNotEmpty ? message : 'Payment failed. Please try again.';
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Recharge')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedOperator,
              items: operators.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
              onChanged: (val) => setState(() => _selectedOperator = val),
              decoration: const InputDecoration(labelText: 'Operator', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : rechargeMobile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Recharge'),
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(message, style: const TextStyle(fontSize: 16, color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
} 