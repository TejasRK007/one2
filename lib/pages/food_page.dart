import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // Selected items
  final Map<String, bool> selectedVegItems = {};
  final Map<String, bool> selectedNonVegItems = {};

  // Price data for items
  final Map<String, double> vegItemPrices = {
    'Carrots': 30.0, 'Tomatoes': 20.0, 'Spinach': 40.0,
    'Cabbage': 25.0, 'Onions': 15.0, 'Potatoes': 18.0,
  };

  final Map<String, double> nonVegItemPrices = {
    'Chicken Breast': 200.0, 'Mutton Curry Cut': 350.0,
    'Fish Fillet': 180.0, 'Prawns': 250.0, 'Eggs': 5.0,
  };

  double calculateTotal(Map<String, bool> selectedItems, Map<String, double> itemPrices) {
    double total = 0.0;
    selectedItems.forEach((item, isSelected) {
      if (isSelected) {
        total += itemPrices[item] ?? 0.0;
      }
    });
    return total;
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
        body: TabBarView(
          children: [
            FoodCategoryView(
              selectedItems: selectedVegItems,
              itemPrices: vegItemPrices,
            ),
            FoodCategoryView(
              selectedItems: selectedNonVegItems,
              itemPrices: nonVegItemPrices,
            ),
          ],
        ),
      ),
    );
  }
}

class FoodCategoryView extends StatefulWidget {
  final Map<String, bool> selectedItems;
  final Map<String, double> itemPrices;

  const FoodCategoryView({
    super.key,
    required this.selectedItems,
    required this.itemPrices,
  });

  @override
  _FoodCategoryViewState createState() => _FoodCategoryViewState();
}

class _FoodCategoryViewState extends State<FoodCategoryView> {
  @override
  Widget build(BuildContext context) {
    double total = 0.0;
    widget.selectedItems.forEach((item, isSelected) {
      if (isSelected) {
        total += widget.itemPrices[item] ?? 0.0;
      }
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...widget.itemPrices.keys.map((item) => FoodItemCard(
          item: item,
          selectedItems: widget.selectedItems,
          itemPrices: widget.itemPrices,
        )),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total: ₹${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class FoodItemCard extends StatefulWidget {
  final String item;
  final Map<String, bool> selectedItems;
  final Map<String, double> itemPrices;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.selectedItems,
    required this.itemPrices,
  });

  @override
  _FoodItemCardState createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    // Initialize isSelected based on whether the item is already selected
    isSelected = widget.selectedItems[widget.item] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.item),
      value: isSelected,
      onChanged: (bool? value) {
        setState(() {
          isSelected = value!;
          // Update the selection status in the parent widget
          widget.selectedItems[widget.item] = isSelected;
        });
      },
      subtitle: Text('₹${widget.itemPrices[widget.item]}'),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FoodPage(),
  ));
}