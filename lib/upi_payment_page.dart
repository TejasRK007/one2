import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'payment_success_page.dart';

class UPIPaymentPage extends StatefulWidget {
  final String cardId;
  final String scannedData;
  final String timestamp;
  final String username;
  final String email;
  final String phone;
  final String password;

  const UPIPaymentPage({
    Key? key,
    required this.cardId,
    required this.scannedData,
    required this.timestamp,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  }) : super(key: key);

  @override
  _UPIPaymentPageState createState() => _UPIPaymentPageState();
}

class _UPIPaymentPageState extends State<UPIPaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool isSubmitting = false;

  Future<void> submitAmount() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;

    final enteredAmount = double.tryParse(_amountController.text.trim());
    if (enteredAmount == null || enteredAmount <= 0) {
      setState(() {
        errorMessage = 'Please enter a valid amount.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = '';
    });

    final userRef = FirebaseDatabase.instance.ref().child('users/${widget.phone}');

    try {
      final balanceSnapshot = await userRef.child('balance').get();
      final currentBalance = balanceSnapshot.exists
          ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0
          : 0.0;

      if (currentBalance < enteredAmount) {
        setState(() {
          errorMessage = 'Insufficient balance.';
          isSubmitting = false;
        });
        return;
      }

      final updatedBalance = currentBalance - enteredAmount;

      await userRef.update({'balance': updatedBalance});

      await userRef.child('transactions').push().set({
        'amount': enteredAmount,
        'timestamp': widget.timestamp,
        'purpose': 'QR Payment - ${widget.scannedData}',
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            amount: enteredAmount,
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitAmount,
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
