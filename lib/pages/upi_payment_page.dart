import 'package:flutter/material.dart';



class UPIPaymentPage extends StatefulWidget {
  final String upiUrl; // still keep it for now, just not using it

  UPIPaymentPage({required this.upiUrl});

  @override
  _UPIPaymentPageState createState() => _UPIPaymentPageState();
}

class _UPIPaymentPageState extends State<UPIPaymentPage> {
  TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _simulatePayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(amount: _amountController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Amount'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter amount to pay', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _simulatePayment,
              icon: Icon(Icons.payment),
              label: Text('Proceed to Pay'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  final String amount;

  PaymentSuccessPage({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Successful'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text('Payment of ₹$amount Successful!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}


