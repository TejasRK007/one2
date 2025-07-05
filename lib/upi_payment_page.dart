import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'payment_success_page.dart';
import 'widgets/upi_pin_dialog.dart';
import 'widgets/rfid_tap_dialog.dart';

class UPIPaymentPage extends StatefulWidget {
  final String cardId;
  final String scannedData;
  final String timestamp;
  final String username;
  final String email;
  final String phone;
  final String password;
  final double? initialAmount;
  final String? upiPin;
  final void Function(String)? onPinSet;

  const UPIPaymentPage({
    Key? key,
    required this.cardId,
    required this.scannedData,
    required this.timestamp,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.initialAmount,
    this.upiPin,
    this.onPinSet,
  }) : super(key: key);

  @override
  _UPIPaymentPageState createState() => _UPIPaymentPageState();
}

class _UPIPaymentPageState extends State<UPIPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  Future<void> submitAmount() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;
    final enteredAmount = double.tryParse(_amountController.text.trim());
    if (enteredAmount == null || enteredAmount <= 0) {
      setState(() {
        errorMessage = 'Please enter a valid amount.';
      });
      return;
    }
    setState(() { isSubmitting = true; errorMessage = ''; });
    // 1. Get user's linked card UID from Firebase
    final userRef = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
    final cardUidSnapshot = await userRef.child('cardUID').get();
    final cardUid = cardUidSnapshot.exists ? cardUidSnapshot.value.toString() : null;
    if (cardUid == null) {
      setState(() {
        errorMessage = 'No card linked to this account.';
        isSubmitting = false;
      });
      return;
    }
    // 2. Show RFID tap dialog
    final tappedUid = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RfidTapDialog(
        phone: widget.phone,
        expectedUid: cardUid,
        amount: enteredAmount,
      ),
    );
    if (tappedUid == null) {
      setState(() {
        errorMessage = 'RFID card tap failed or cancelled.';
        isSubmitting = false;
      });
      return;
    }
    // 3. Deduct from card balance already done in dialog, now update user balance and log transaction
    try {
      final balanceSnapshot = await userRef.child('balance').get();
      final currentBalance = balanceSnapshot.exists ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0 : 0.0;
      if (currentBalance < enteredAmount) {
        setState(() {
          errorMessage = 'Insufficient app balance.';
          isSubmitting = false;
        });
        return;
      }
      final updatedBalance = currentBalance - enteredAmount;
      await userRef.update({'balance': updatedBalance});
      // Increment reward points and log history
      final rewardPointsSnapshot = await userRef.child('rewardPoints').get();
      final currentPoints = rewardPointsSnapshot.exists ? int.tryParse(rewardPointsSnapshot.value.toString()) ?? 0 : 0;
      final newPoints = currentPoints + 1;
      await userRef.update({'rewardPoints': newPoints});
      await userRef.child('rewardHistory').push().set({
        'points': 1,
        'timestamp': widget.timestamp,
        'description': 'Earned for QR Payment',
      });
      await userRef.child('transactions').push().set({
        'amount': enteredAmount,
        'timestamp': widget.timestamp,
        'purpose': 'QR Payment - ${widget.scannedData}',
      });
      // Add notification
      await userRef.child('notifications').push().set({
        'title': 'Payment Successful',
        'body': 'You paid ₹${enteredAmount.toStringAsFixed(2)} to ${widget.scannedData}. 1 reward point awarded.',
        'timestamp': widget.timestamp,
        'read': false,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            amount: enteredAmount,
            recipient: widget.scannedData,
            username: widget.username,
            email: widget.email,
            phone: widget.phone,
            password: widget.password,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update balance: $e';
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Amount')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.scannedData.isNotEmpty)
                Column(
                  children: [
                    const Text('Payment For:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.scannedData, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                  ],
                ),
              Text('Card ID: ${widget.cardId}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Amount (Virtual Money)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
                enabled: widget.initialAmount == null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitAmount,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
