// ✅ FILE: transport_fare_payment_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'payment_success_page.dart';
import 'widgets/upi_pin_dialog.dart';

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
    final pinVerified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => UpiPinDialog(
        currentPin: widget.upiPin,
        onPinVerified: (_) async {
          try {
            setState(() {
              isSubmitting = true;
              errorMessage = '';
            });
            final userRef = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
            final balanceSnapshot = await userRef.child('balance').get();
            final currentBalance = balanceSnapshot.exists
                ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0
                : 0.0;
            if (currentBalance < widget.amount) {
              setState(() {
                errorMessage = 'Insufficient balance.';
                isSubmitting = false;
              });
              Navigator.of(dialogContext).pop(false);
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
            if (!mounted) return;
            Navigator.of(dialogContext).pop(true);
          } catch (e) {
            setState(() {
              errorMessage = 'Payment failed: $e';
              isSubmitting = false;
            });
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
            amount: widget.amount,
            recipient: widget.scannedData,
            username: widget.username,
            email: widget.email,
            phone: widget.phone,
            password: widget.password,
          ),
        ),
      );
    } else {
      setState(() {
        errorMessage = errorMessage.isNotEmpty ? errorMessage : 'Payment failed. Please try again.';
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