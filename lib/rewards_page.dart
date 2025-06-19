import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RewardsPage extends StatefulWidget {
  final String phone;
  final String username;
  final String email;
  final String password;

  const RewardsPage({
    super.key,
    required this.phone,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int? rewardPoints;
  bool isLoading = true;
  String error = '';
  List<Map<String, dynamic>> rewardHistory = [];

  @override
  void initState() {
    super.initState();
    fetchRewardPoints();
    fetchRewardHistory();
  }

  Future<void> fetchRewardPoints() async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}/rewardPoints');
      final snapshot = await ref.get();
      setState(() {
        rewardPoints = snapshot.exists ? int.tryParse(snapshot.value.toString()) ?? 0 : 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load reward points.';
        isLoading = false;
      });
    }
  }

  Future<void> fetchRewardHistory() async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}/rewardHistory');
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        final historyMap = Map<String, dynamic>.from(snapshot.value as Map);
        rewardHistory = historyMap.values.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        rewardHistory.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
      } else {
        rewardHistory = [];
      }
      setState(() {});
    } catch (e) {
      // Ignore history errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rewards")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error.isNotEmpty
                ? Text(error, style: const TextStyle(color: Colors.red))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, size: 60, color: Colors.amber),
                      const SizedBox(height: 20),
                      Text(
                        'You have',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${rewardPoints ?? 0} reward points',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                      if ((rewardPoints ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.local_offer),
                            label: const Text('View Discount Offers'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DiscountOffersPage(
                                    phone: widget.phone,
                                    rewardPoints: rewardPoints ?? 0,
                                  ),
                                ),
                              );
                              if (updated == true) {
                                fetchRewardPoints();
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: 30),
                      Text('Reward History', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Expanded(
                        child: rewardHistory.isEmpty
                            ? const Text('No reward history yet.')
                            : ListView.builder(
                                itemCount: rewardHistory.length,
                                itemBuilder: (context, index) {
                                  final entry = rewardHistory[index];
                                  return ListTile(
                                    leading: const Icon(Icons.star, color: Colors.amber),
                                    title: Text('+${entry['points']} points'),
                                    subtitle: Text(entry['description'] ?? ''),
                                    trailing: Text(entry['timestamp'] ?? ''),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class DiscountOffersPage extends StatefulWidget {
  final String phone;
  final int rewardPoints;
  const DiscountOffersPage({super.key, required this.phone, required this.rewardPoints});

  @override
  State<DiscountOffersPage> createState() => _DiscountOffersPageState();
}

class _DiscountOffersPageState extends State<DiscountOffersPage> {
  final List<DiscountOffer> offers = [
    DiscountOffer('Amazon ₹100 Gift Card', 100, 'assets/offers/amazon.png'),
    DiscountOffer('Flipkart ₹100 Gift Card', 100, 'assets/offers/flipkart.png'),
    DiscountOffer('Swiggy 20% Off Coupon', 80, 'assets/offers/swiggy.png'),
    DiscountOffer('Zomato 20% Off Coupon', 80, 'assets/offers/zomato.png'),
    DiscountOffer('Uber ₹50 Ride Credit', 60, 'assets/offers/uber.png'),
    DiscountOffer('BookMyShow ₹100 Off', 90, 'assets/offers/bookmyshow.png'),
    DiscountOffer('Myntra ₹150 Off', 120, 'assets/offers/myntra.png'),
    DiscountOffer('BigBasket ₹50 Off', 60, 'assets/offers/bigbasket.png'),
    DiscountOffer('Croma ₹200 Off', 150, 'assets/offers/croma.png'),
    DiscountOffer("Domino's 25% Off", 70, 'assets/offers/dominos.png'),
  ];
  bool isRedeeming = false;
  String message = '';

  Future<void> redeemOffer(DiscountOffer offer) async {
    setState(() {
      isRedeeming = true;
      message = '';
    });
    if (widget.rewardPoints < offer.requiredPoints) {
      setState(() {
        message = 'Not enough points!';
        isRedeeming = false;
      });
      return;
    }
    try {
      final ref = FirebaseDatabase.instance.ref().child('users/${widget.phone}');
      final pointsSnapshot = await ref.child('rewardPoints').get();
      final currentPoints = pointsSnapshot.exists ? int.tryParse(pointsSnapshot.value.toString()) ?? 0 : 0;
      if (currentPoints < offer.requiredPoints) {
        setState(() {
          message = 'Not enough points!';
          isRedeeming = false;
        });
        return;
      }
      await ref.update({'rewardPoints': currentPoints - offer.requiredPoints});
      await ref.child('rewardHistory').push().set({
        'points': -offer.requiredPoints,
        'timestamp': DateTime.now().toString(),
        'description': 'Redeemed: ${offer.title}',
      });
      setState(() {
        message = 'Redeemed! Check your email for the offer.';
        isRedeeming = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        message = 'Redemption failed.';
        isRedeeming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discount Offers'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Points: ${widget.rewardPoints}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  final canRedeem = widget.rewardPoints >= offer.requiredPoints;
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          offer.logoAsset,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.local_offer, size: 40),
                        ),
                      ),
                      title: Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${offer.requiredPoints} points'),
                      trailing: ElevatedButton(
                        onPressed: isRedeeming || !canRedeem ? null : () => redeemOffer(offer),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canRedeem ? Colors.indigo : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: isRedeeming ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Redeem'),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text(message, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ),
          ],
        ),
      ),
    );
  }
}

class DiscountOffer {
  final String title;
  final int requiredPoints;
  final String logoAsset;
  DiscountOffer(this.title, this.requiredPoints, this.logoAsset);
}