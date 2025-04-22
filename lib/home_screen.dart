import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/banking_page.dart';
import 'pages/transport_page.dart';
import 'pages/food_page.dart';
import 'pages/qr_scan_page.dart';
import 'pages/rewards_page.dart';
import 'pages/history_page.dart';
import 'widgets/feature_card.dart';
import 'widgets/explore_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePageContent(),
    QRScanPage(),
    RewardsPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.redeem), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Welcome RK 👋',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Explore your digital services',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              const Text(
                'Your Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FeatureCard(
                      title: 'Identity',
                      icon: Icons.perm_identity,
                      onTap: () {
                        navigateTo(context, const ProfilePage());
                      },
                    ),
                    FeatureCard(
                      title: 'Banking',
                      icon: Icons.account_balance,
                      onTap: () {
                        navigateTo(context, const BankingPage());
                      },
                    ),
                    FeatureCard(
                      title: 'Transport',
                      icon: Icons.directions_bus,
                      onTap: () {
                        navigateTo(context, const TransportPage());
                      },
                    ),
                    FeatureCard(
                      title: 'Food',
                      icon: Icons.restaurant,
                      onTap: () {
                        navigateTo(context, const FoodPage());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Explore More',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  ExploreIcon(icon: Icons.qr_code, label: 'Scan'),
                  ExploreIcon(icon: Icons.redeem, label: 'Rewards'),
                  ExploreIcon(icon: Icons.history, label: 'History'),
                  ExploreIcon(icon: Icons.settings, label: 'Settings'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
