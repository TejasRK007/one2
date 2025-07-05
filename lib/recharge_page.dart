import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/rfid_tap_dialog.dart';
import 'payment_success_page.dart';
import 'widgets/upi_pin_dialog.dart';

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
  String _rechargeMethod = 'card'; // 'card' or 'upi'
  String? _sessionUpiPin;

  Future<void> rechargeBalance() async {
    final enteredAmount = double.tryParse(_controller.text.trim());
    if (enteredAmount == null || enteredAmount <= 0) {
      setState(() => message = 'Enter a valid amount');
      return;
    }
    setState(() { message = ''; });
    final userRef = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
    final cardUidSnapshot = await userRef.child('cardUID').get();
    final cardUid = cardUidSnapshot.exists ? cardUidSnapshot.value.toString() : null;
    if (cardUid == null) {
      setState(() => message = 'No card linked to this account.');
      return;
    }
    String? tappedUid;
    // Handle UPI PIN for UPI recharge
    if (_rechargeMethod == 'upi') {
      if (_sessionUpiPin == null && (widget.upiPin == null || widget.upiPin!.isEmpty)) {
        // Ask to set UPI PIN
        final setPin = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => UpiPinDialog(
            currentPin: null,
            onPinSet: (pin) {
              setState(() { _sessionUpiPin = pin; });
              if (widget.onPinSet != null) widget.onPinSet!(pin);
            },
            onPinVerified: (_) {},
          ),
        );
        if (setPin != true) {
          setState(() => message = 'UPI PIN setup cancelled.');
          return;
        }
      } else {
        // Ask to enter UPI PIN
        final pinToCheck = _sessionUpiPin ?? widget.upiPin;
        final verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => UpiPinDialog(
            currentPin: pinToCheck,
            onPinSet: (_) {},
            onPinVerified: (_) {},
          ),
        );
        if (verified != true) {
          setState(() => message = 'UPI PIN verification failed or cancelled.');
          return;
        }
      }
    } else if (_rechargeMethod == 'card') {
      tappedUid = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => RfidTapDialog(
          phone: widget.phone,
          expectedUid: cardUid,
          amount: enteredAmount,
          isRecharge: true, // new flag
        ),
      );
      if (tappedUid == null) {
        setState(() => message = 'RFID card tap failed or cancelled.');
        return;
      }
    }
    try {
      final balanceRef = userRef.child('balance');
      final snapshot = await balanceRef.get();
      double current = snapshot.exists ? double.tryParse(snapshot.value.toString()) ?? 0.0 : 0.0;
      final updated = current + enteredAmount;
      await balanceRef.set(updated);
      // Increment reward points and log history
      final rewardPointsSnapshot = await userRef.child('rewardPoints').get();
      final currentPoints = rewardPointsSnapshot.exists ? int.tryParse(rewardPointsSnapshot.value.toString()) ?? 0 : 0;
      final newPoints = currentPoints + 1;
      await userRef.update({'rewardPoints': newPoints});
      await userRef.child('rewardHistory').push().set({
        'points': 1,
        'timestamp': DateTime.now().toString(),
        'description': 'Earned for Wallet Recharge',
      });
      await userRef.child('transactions').push().set({
        'amount': enteredAmount,
        'timestamp': DateTime.now().toString(),
        'purpose': 'Wallet Recharge',
      });
      // Add notification
      await userRef.child('notifications').push().set({
        'title': 'Wallet Recharged',
        'body': 'You recharged your wallet with ₹${enteredAmount.toStringAsFixed(2)}. 1 reward point awarded.',
        'timestamp': DateTime.now().toString(),
        'read': false,
      });
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
    } catch (e) {
      setState(() => message = 'Recharge failed: $e');
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Recharge via Card'),
                    value: 'card',
                    groupValue: _rechargeMethod,
                    onChanged: (val) => setState(() => _rechargeMethod = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Recharge via UPI'),
                    value: 'upi',
                    groupValue: _rechargeMethod,
                    onChanged: (val) => setState(() => _rechargeMethod = val!),
                  ),
                ),
              ],
            ),
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
