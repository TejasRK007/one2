//payment_success_page
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String amount;

  const PaymentSuccessPage({Key? key, required this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Success')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Payment of ₹$amount was successful!',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('Back to Home'),
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
