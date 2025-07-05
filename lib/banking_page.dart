import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/upi_pin_dialog.dart';
import 'account_details_page.dart';
import 'dart:math';

class BankingPage extends StatefulWidget {
  final String phone;
  final String username;
  final String email;
  final String password;
  final String? upiPin;
  final void Function(String)? onPinSet;
  final String? cardUID;

  const BankingPage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
    this.upiPin,
    this.onPinSet,
    this.cardUID,
  });

  @override
  State<BankingPage> createState() => _BankingPageState();
}

class _BankingPageState extends State<BankingPage> {
  bool isLoading = false;

  void _askPin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    // Check if UPI PIN is set
    if (widget.upiPin == null || widget.upiPin!.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a UPI PIN first in Settings'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final pinVerified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => UpiPinDialog(
            currentPin: widget.upiPin,
            onPinVerified: (_) {
              Navigator.of(dialogContext).pop(true);
            },
            onPinSet: widget.onPinSet,
          ),
    );

    setState(() {
      isLoading = false;
    });

    if (pinVerified == true) {
      // Navigate to account details page after successful PIN verification
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => AccountDetailsPage(
                phone: widget.phone,
                username: widget.username,
                email: widget.email,
                password: widget.password,
                cardUID: widget.cardUID,
              ),
        ),
      );
    } else if (pinVerified == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Access Bank",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bank Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'ACCESS BANK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure Banking Access',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Access Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _askPin(context),
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.lock, size: 24),
                    label: Text(
                      isLoading ? 'Verifying...' : 'View Account Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),

                // Set UPI PIN Button (if not set)
                if (widget.upiPin == null || widget.upiPin!.isEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final pinSet = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (dialogContext) => UpiPinDialog(
                                currentPin: null,
                                onPinVerified: (_) {},
                                onPinSet: (pin) {
                                  widget.onPinSet?.call(pin);
                                  Navigator.of(dialogContext).pop(true);
                                },
                              ),
                        );
                        if (pinSet == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'UPI PIN set successfully! You can now access your bank account.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.pin, size: 20),
                      label: const Text(
                        'Set UPI PIN First',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Security Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Secure Banking Access',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.upiPin != null && widget.upiPin!.isNotEmpty
                            ? 'Your account details are protected with UPI PIN'
                            : 'Set a UPI PIN to access your bank account securely',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
