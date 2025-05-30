import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final Map<String, bool> selectedVegItems = {};
  final Map<String, bool> selectedNonVegItems = {};

  final Map<String, double> vegItemPrices = {
    'Carrots': 35.0,
    'Tomatoes': 25.0,
    'Spinach': 45.0,
    'Cabbage': 30.0,
    'Onions': 20.0,
    'Potatoes': 22.0,
    'Broccoli': 55.0,
    'Cauliflower': 33.0,
    'Green Peas': 40.0,
    'Sweet Corn': 35.0,
    'Bell Peppers': 50.0,
    'Mushrooms': 65.0,
    'Lettuce': 30.0,
    'Beetroot': 28.0,
    'Pumpkin': 32.0,
    'Radish': 18.0,
    'Cucumber': 25.0,
    'Zucchini': 38.0,
    'Brinjal': 26.0,
  };

  final Map<String, double> nonVegItemPrices = {
    'Chicken Breast': 220.0,
    'Mutton Curry Cut': 380.0,
    'Fish Fillet': 200.0,
    'Prawns': 270.0,
    'Eggs': 6.0,
    'Chicken Leg Piece': 240.0,
    'Mutton Biryani': 330.0,
    'Fish Curry': 260.0,
    'Crab Meat': 300.0,
    'Duck Meat': 350.0,
    'Quail Eggs': 14.0,
    'Fried Chicken': 210.0,
    'Grilled Fish': 290.0,
    'Turkey Breast': 310.0,
    'Lamb Chops': 360.0,
    'Shrimp Curry': 285.0,
  };

  double get total {
    double totalVeg = selectedVegItems.entries
        .where((e) => e.value)
        .fold(0.0, (sum, e) => sum + (vegItemPrices[e.key] ?? 0.0));
    double totalNonVeg = selectedNonVegItems.entries
        .where((e) => e.value)
        .fold(0.0, (sum, e) => sum + (nonVegItemPrices[e.key] ?? 0.0));
    return totalVeg + totalNonVeg;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Services'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vegetarian'),
              Tab(text: 'Non-Vegetarian'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  FoodCategoryView(
                    selectedItems: selectedVegItems,
                    itemPrices: vegItemPrices,
                    onItemChanged: () => setState(() {}),
                  ),
                  FoodCategoryView(
                    selectedItems: selectedNonVegItems,
                    itemPrices: nonVegItemPrices,
                    onItemChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodCategoryView extends StatelessWidget {
  final Map<String, bool> selectedItems;
  final Map<String, double> itemPrices;
  final VoidCallback onItemChanged;

  const FoodCategoryView({
    super.key,
    required this.selectedItems,
    required this.itemPrices,
    required this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: itemPrices.keys.map((item) {
        bool isSelected = selectedItems[item] ?? false;
        return CheckboxListTile(
          title: Text(item),
          value: isSelected,
          onChanged: (bool? value) {
            selectedItems[item] = value ?? false;
            onItemChanged();
          },
          subtitle: Text('₹${itemPrices[item]}'),
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FoodPage(),
  ));
}