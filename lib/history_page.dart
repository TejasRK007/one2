import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPage extends StatefulWidget {
  final String phone;
  final String username;
  final String email;
  final String password;

  const HistoryPage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}/transactions');
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        final txMap = Map<String, dynamic>.from(snapshot.value as Map);
        transactions = txMap.values.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        transactions.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      } else {
        transactions = [];
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load transactions.';
        isLoading = false;
      });
    }
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    // Try to parse as DateTime
    try {
      final dt = DateTime.tryParse(timestamp);
      if (dt != null) {
        return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return timestamp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
              : transactions.isEmpty
                  ? const Center(child: Text("No transactions yet."))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final amount = tx['amount'] ?? 0;
                        final purpose = (tx['purpose'] ?? '').toString();
                        final timestamp = formatTimestamp(tx['timestamp']?.toString());
                        final isRecharge = purpose.toLowerCase().contains('recharge');
                        final isPayment = purpose.toLowerCase().contains('payment') || purpose.toLowerCase().contains('paid');
                        final isBill = purpose.toLowerCase().contains('bill');
                        IconData icon;
                        Color color;
                        if (isRecharge) {
                          icon = Icons.add_card;
                          color = Colors.green;
                        } else if (isPayment) {
                          icon = Icons.payment;
                          color = Colors.indigo;
                        } else if (isBill) {
                          icon = Icons.receipt_long;
                          color = Colors.orange;
                        } else {
                          icon = Icons.history;
                          color = Colors.grey;
                        }
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withOpacity(0.15),
                                  radius: 28,
                                  child: Icon(icon, color: color, size: 32),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        purpose,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\u20b9${amount.toString()}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.indigo),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(timestamp, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}