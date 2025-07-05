// ✅ FILE: transport_fare_payment_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'payment_success_page.dart';
import 'widgets/rfid_tap_dialog.dart';

class TransportFarePaymentPage extends StatefulWidget {
  final double amount;
  final String cardId;
  final String scannedData;
  final String timestamp;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String? upiPin;
  final void Function(String)? onPinSet;

  const TransportFarePaymentPage({
    Key? key,
    required this.amount,
    required this.cardId,
    required this.scannedData,
    required this.timestamp,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.upiPin,
    this.onPinSet,
  }) : super(key: key);

  @override
  State<TransportFarePaymentPage> createState() => _TransportFarePaymentPageState();
}

class _TransportFarePaymentPageState extends State<TransportFarePaymentPage> {
  bool isSubmitting = false;
  String errorMessage = '';

  Future<void> submitPayment() async {
    if (isSubmitting) return;
    setState(() { isSubmitting = true; errorMessage = ''; });
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
    final tappedUid = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RfidTapDialog(
        phone: widget.phone,
        expectedUid: cardUid,
        amount: widget.amount,
      ),
    );
    if (tappedUid == null) {
      setState(() {
        errorMessage = 'RFID card tap failed or cancelled.';
        isSubmitting = false;
      });
      return;
    }
    try {
      final balanceSnapshot = await userRef.child('balance').get();
      final currentBalance = balanceSnapshot.exists ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0 : 0.0;
      if (currentBalance < widget.amount) {
        setState(() {
          errorMessage = 'Insufficient app balance.';
          isSubmitting = false;
        });
        return;
      }
      final updatedBalance = currentBalance - widget.amount;
      await userRef.update({'balance': updatedBalance});
      final rewardPointsSnapshot = await userRef.child('rewardPoints').get();
      final currentPoints = rewardPointsSnapshot.exists ? int.tryParse(rewardPointsSnapshot.value.toString()) ?? 0 : 0;
      final newPoints = currentPoints + 1;
      await userRef.update({'rewardPoints': newPoints});
      await userRef.child('rewardHistory').push().set({
        'points': 1,
        'timestamp': widget.timestamp,
        'description': 'Earned for Transport Payment',
      });
      await userRef.child('transactions').push().set({
        'amount': widget.amount,
        'timestamp': widget.timestamp,
        'purpose': 'Transport Booking - ${widget.scannedData}',
      });
      await userRef.child('notifications').push().set({
        'title': 'Transport Fare Paid',
        'body': 'You paid ₹${widget.amount.toStringAsFixed(2)} for ${widget.scannedData}. 1 reward point awarded.',
        'timestamp': widget.timestamp,
        'read': false,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            amount: widget.amount,
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
        errorMessage = 'Payment failed: $e';
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Fare Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scanned Data: ${widget.scannedData}'),
            const SizedBox(height: 10),
            Text('Amount to Pay: ₹${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : submitPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay Now'),
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
    );
  }
}