import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'dart:async';

class AccountDetailsPage extends StatefulWidget {
  final String phone;
  final String username;
  final String email;
  final String password;
  final String? cardUID;

  const AccountDetailsPage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
    this.cardUID,
  });

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  double balance = 0.0;
  String accountNumber = '';
  String ifscCode = '';
  int emiCount = 0;
  String emiDetails = '';
  bool isLoading = true;
  StreamSubscription<DatabaseEvent>? _balanceSubscription;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
    _listenToBalanceChanges();
  }

  void _listenToBalanceChanges() {
    final balanceRef = FirebaseDatabase.instance.ref().child(
      'users/${widget.phone}/balance',
    );
    _balanceSubscription = balanceRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final newBalance =
            double.tryParse(event.snapshot.value.toString()) ?? 0.0;
        if (mounted) {
          setState(() {
            balance = newBalance;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAccountDetails() async {
    try {
      final ref = FirebaseDatabase.instance.ref().child(
        'users/${widget.phone}',
      );
      final balanceSnapshot = await ref.child('balance').get();
      final balance =
          balanceSnapshot.exists
              ? double.tryParse(balanceSnapshot.value.toString()) ?? 0.0
              : 0.0;

      final emiSnapshot = await ref.child('emis').get();
      int emiCount = 0;
      String emiDetails = '';
      if (emiSnapshot.exists && emiSnapshot.value != null) {
        if (emiSnapshot.value is Map) {
          final emis = Map<String, dynamic>.from(emiSnapshot.value as Map);
          emiCount = emis.length;
          emiDetails = emis.entries
              .map((e) {
                final v = e.value;
                if (v is Map && v['amount'] != null && v['dueDate'] != null) {
                  return '₹${v['amount']} due on ${v['dueDate']}';
                } else if (v is Map && v['amount'] != null) {
                  return '₹${v['amount']}';
                } else if (v is String) {
                  return v;
                } else {
                  return 'EMI';
                }
              })
              .join('\n');
        } else if (emiSnapshot.value is List) {
          final emis = List.from(emiSnapshot.value as List);
          emiCount = emis.length;
          emiDetails = emis
              .map((v) {
                if (v is Map && v['amount'] != null && v['dueDate'] != null) {
                  return '₹${v['amount']} due on ${v['dueDate']}';
                } else if (v is Map && v['amount'] != null) {
                  return '₹${v['amount']}';
                } else if (v is String) {
                  return v;
                } else {
                  return 'EMI';
                }
              })
              .join('\n');
        }
      }

      // Generate account details
      final random = Random();
      final accountNumber = List.generate(12, (_) => random.nextInt(10)).join();
      final ifscCode = 'ACCESS${random.nextInt(900000) + 100000}';

      // Use the actual balance from Firebase, no fallback needed
      final finalBalance = balance;

      if (mounted) {
        setState(() {
          this.balance = finalBalance;
          this.accountNumber = accountNumber;
          this.ifscCode = ifscCode;
          this.emiCount = emiCount;
          this.emiDetails = emiDetails;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading account details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _loadAccountDetails();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account details refreshed'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACCESS BANK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Account Details',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child:
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E3A8A),
                              ),
                            ),
                          )
                          : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Balance Card (Special)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1E3A8A),
                                        Color(0xFF3B82F6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1E3A8A,
                                        ).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.account_balance,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Text(
                                            'Current Balance',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '₹${balance.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Account Details Section
                                const Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildDetailCard(
                                  'Account Holder',
                                  widget.username,
                                  Icons.person,
                                  const Color(0xFF1E3A8A),
                                ),
                                _buildDetailCard(
                                  'Account Number',
                                  accountNumber,
                                  Icons.account_balance_wallet,
                                  const Color(0xFF3B82F6),
                                ),
                                _buildDetailCard(
                                  'Phone Number',
                                  widget.phone,
                                  Icons.phone,
                                  const Color(0xFF10B981),
                                ),
                                _buildDetailCard(
                                  'IFSC Code',
                                  ifscCode,
                                  Icons.code,
                                  const Color(0xFFF59E0B),
                                ),
                                _buildDetailCard(
                                  'Branch',
                                  'Mumbai Main Branch',
                                  Icons.location_on,
                                  const Color(0xFFEF4444),
                                ),
                                _buildDetailCard(
                                  'Linked Card',
                                  widget.cardUID != null &&
                                          widget.cardUID!.isNotEmpty
                                      ? 'Card Linked'
                                      : 'No Card Linked',
                                  Icons.credit_card,
                                  const Color(0xFF8B5CF6),
                                ),

                                const SizedBox(height: 24),

                                // EMI Section
                                const Text(
                                  'EMI Status',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                if (emiCount > 0) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warning,
                                              color: Colors.orange[700],
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'EMIs Pending: $emiCount',
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          emiDetails,
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green[700],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'No EMIs or instalments pending',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
