import 'package:flutter/material.dart';
import 'payment_success_page.dart';
import 'widgets/upi_pin_dialog.dart';
import 'widgets/rfid_tap_dialog.dart';
import 'package:firebase_database/firebase_database.dart';

class TapPaymentPage extends StatefulWidget {
  final String? upiPin;
  final String username;
  final String email;
  final String phone;
  final String password;
  final void Function(String)? onPinSet;

  const TapPaymentPage({
    super.key,
    required this.upiPin,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.onPinSet,
  });

  @override
  _TapPaymentPageState createState() => _TapPaymentPageState();
}

class _TapPaymentPageState extends State<TapPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Transport';
  double? _amount;
  final _pinController = TextEditingController();

  final List<String> _categories = ['Transport', 'Food', 'Mobile Recharge', 'WiFi Recharge', 'Shopping'];

  void _showPinDialogAndPay() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final userRef = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
      final cardUidSnapshot = await userRef.child('cardUID').get();
      final cardUid = cardUidSnapshot.exists ? cardUidSnapshot.value.toString() : null;
      if (cardUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No card linked to this account.')),
        );
        return;
      }
      // Show tap dialog and handle payment immediately after successful tap
      final tappedUid = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => RfidTapDialog(
          phone: widget.phone,
          expectedUid: cardUid,
          amount: _amount!,
          onCardVerified: (uid) async {
            // Deduct from app balance and log transaction
            try {
              final balanceSnapshot = await userRef.child('balance').get();
              final currentBalance = balanceSnapshot.exists ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0 : 0.0;
              if (currentBalance < _amount!) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insufficient app balance.')),
                  );
                }
                return;
              }
              final updatedBalance = currentBalance - _amount!;
              await userRef.update({'balance': updatedBalance});
              await userRef.child('transactions').push().set({
                'amount': _amount!,
                'timestamp': DateTime.now().toString(),
                'purpose': _selectedCategory,
              });
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentSuccessPage(
                      amount: _amount!,
                      recipient: _selectedCategory,
                      username: widget.username,
                      email: widget.email,
                      phone: widget.phone,
                      password: widget.password,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment failed: $e')),
                );
              }
            }
          },
        ),
      );
      if (tappedUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RFID card tap failed or cancelled.')),
        );
        return;
      }
      // No need to show success page here, it's handled in onCardVerified
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (widget.upiPin == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please set a UPI PIN in settings first.')),
                    );
                    return;
                  }
                  _showPinDialogAndPay();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Proceed to Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 