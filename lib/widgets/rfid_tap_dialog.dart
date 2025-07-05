import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class RfidTapDialog extends StatefulWidget {
  final String phone;
  final String expectedUid;
  final double amount;
  final void Function(String)? onCardVerified;
  final bool isRecharge;

  const RfidTapDialog({
    Key? key,
    required this.phone,
    required this.expectedUid,
    required this.amount,
    this.onCardVerified,
    this.isRecharge = false,
  }) : super(key: key);

  @override
  State<RfidTapDialog> createState() => _RfidTapDialogState();
}

class _RfidTapDialogState extends State<RfidTapDialog> {
  late DatabaseReference _pendingLinkRef;
  StreamSubscription<DatabaseEvent>? _subscription;
  String _status = 'Please tap your RFID card...';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _pendingLinkRef = FirebaseDatabase.instance.ref('pending_links/${widget.phone}');
    _pendingLinkRef.set(null); // Clear previous
    _subscription = _pendingLinkRef.onValue.listen(_onEvent);
    // Tell Arduino which phone to listen for
    FirebaseDatabase.instance.ref('link_target/phone').set(widget.phone);
  }

  void _onEvent(DatabaseEvent event) async {
    if (_isVerifying) return;
    if (event.snapshot.value != null) {
      final value = event.snapshot.value;
      String? cardUid;
      if (value is String) {
        cardUid = value;
      } else if (value is Map && value['uid'] != null) {
        cardUid = value['uid'].toString();
      } else if (value is num) {
        cardUid = value.toString();
      }
      if (cardUid != null && cardUid.isNotEmpty) {
        setState(() { _isVerifying = true; _status = 'Verifying card...'; });
        if (cardUid == widget.expectedUid) {
          // Only verify UID, do not check/deduct card balance
          final userRef = FirebaseDatabase.instance.ref('users/${widget.phone}/balance');
          final userBalanceSnapshot = await userRef.get();
          double userCurrent = userBalanceSnapshot.exists ? double.tryParse(userBalanceSnapshot.value.toString()) ?? 0.0 : 0.0;
          if (!widget.isRecharge && userCurrent < widget.amount) {
            setState(() { _status = 'Insufficient balance!'; });
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) Navigator.of(context).pop(null);
            return;
          }
          await _pendingLinkRef.remove();
          if (widget.onCardVerified != null) widget.onCardVerified!(cardUid);
          if (mounted) Navigator.of(context).pop(cardUid);
          return;
        } else {
          setState(() { _status = 'Card not linked to this account!'; });
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.of(context).pop(null);
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pendingLinkRef.set(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tap RFID Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.nfc, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          Text(_status, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
} 