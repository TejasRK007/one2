import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LinkCardPage extends StatefulWidget {
  final String phone;
  final Function(String) onCardLinked;

  const LinkCardPage({
    super.key,
    required this.phone,
    required this.onCardLinked,
  });

  @override
  _LinkCardPageState createState() => _LinkCardPageState();
}

class _LinkCardPageState extends State<LinkCardPage> {
  late DatabaseReference _pendingLinkRef;
  StreamSubscription<DatabaseEvent>? _pendingLinkSubscription;
  bool _isListening = false;
  String _statusMessage = 'Press "Start" and tap your card on the reader.';

  @override
  void initState() {
    super.initState();
    _pendingLinkRef = FirebaseDatabase.instance.ref('pending_links/${widget.phone}');
    print("👤 Listening for phone: ${widget.phone}");
  }

  void _startListening() {
    // ✅ Tell Arduino which phone number to link
    FirebaseDatabase.instance.ref('link_target/phone').set(widget.phone);

    setState(() {
      _isListening = true;
      _statusMessage = 'Listening for card tap...';
    });

    // Clear previous UID
    _pendingLinkRef.set(null);

    _pendingLinkSubscription = _pendingLinkRef.onValue.listen((event) {
      print("🔥 Firebase event received");
      print("📦 Firebase data: ${event.snapshot.value}");

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

        print("✅ Parsed UID: $cardUid");

        if (cardUid != null && cardUid.isNotEmpty) {
          _pendingLinkSubscription?.cancel();
          _pendingLinkSubscription = null;
          _updateUIOnSuccess(cardUid);
          _performBackgroundLinking(cardUid);
        }
      }
    });
  }

  void _updateUIOnSuccess(String cardUid) {
    if (!mounted) return;

    setState(() {
      _isListening = false;
      _statusMessage = 'Successfully linked card: $cardUid';
    });

    widget.onCardLinked(cardUid);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Card registration successful!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Pop LinkCardPage
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackgroundLinking(String cardUid) async {
    final userRef = FirebaseDatabase.instance.ref('users/${widget.phone}');
    await userRef.child('cardUID').set(cardUid);

    final cardRef = FirebaseDatabase.instance.ref('cards/$cardUid');
    await cardRef.child('userPhone').set(widget.phone);

    await _pendingLinkRef.remove();
  }

  @override
  void dispose() {
    _pendingLinkSubscription?.cancel();
    _pendingLinkRef.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link RFID Card')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.credit_card_sharp, size: 100, color: Colors.indigo),
            const SizedBox(height: 24),
            Text(
              'Link Your Card',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isListening ? null : _startListening,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: _isListening
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  SizedBox(width: 24),
                  Text('Waiting for tap...'),
                ],
              )
                  : const Text('Start Linking'),
            ),
          ],
        ),
      ),
    );
  }
}
