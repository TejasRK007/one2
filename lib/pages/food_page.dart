import 'package:flutter/material.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

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
        body: const TabBarView(
          children: [
            FoodCategoryView(isVeg: true),
            FoodCategoryView(isVeg: false),
          ],
        ),
      ),
    );
  }
}

class FoodCategoryView extends StatelessWidget {
  final bool isVeg;
  const FoodCategoryView({super.key, required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final groceries = isVeg ? vegGroceries : nonVegGroceries;
    final restaurants = isVeg ? vegRestaurants : nonVegRestaurants;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Groceries", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...groceries.map((item) => FoodItemCard(item: item)),

        const SizedBox(height: 20),
        Text("Restaurants", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...restaurants.map((item) => FoodItemCard(item: item)),
      ],
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String item;
  const FoodItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.fastfood, color: Colors.orange),
        title: Text(item),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

// Dummy data
const List<String> vegGroceries = [
  'Carrots', 'Tomatoes', 'Spinach', 'Cabbage', 'Onions',
  'Potatoes', 'Beans', 'Peas', 'Cucumber', 'Pumpkin',
  'Broccoli', 'Cauliflower', 'Beetroot', 'Radish', 'Corn',
  'Green Chilli', 'Ginger', 'Garlic', 'Brinjal', 'Mushroom'
];

const List<String> vegRestaurants = [
  'Green Leaf Café', 'Veg Delight', 'Sattvic Bites', 'The Organic Bowl',
  'Pure Veg Kitchen', 'Nature’s Basket', 'Tandoori Veg', 'Flavors of India',
  'Bhojan Bhavan', 'Udupi Palace', 'Khana Khazana', 'Gujarati Rasoi',
  'Rajasthani Thali', 'Idli & Dosa Hub', 'Herbivore Heaven',
  'Sattvik Bhojanalaya', 'Annapurna Sweets', 'Farm Fresh Meals', 'South Spice', 'A2B Veg'
];

const List<String> nonVegGroceries = [
  'Chicken Breast', 'Mutton Curry Cut', 'Fish Fillet', 'Prawns',
  'Eggs', 'Chicken Wings', 'Turkey Slices', 'Beef Mince', 'Salmon',
  'Duck Legs', 'Goat Meat', 'Crab Meat', 'Squid Rings', 'Lobster',
  'Smoked Ham', 'Chicken Drumsticks', 'Quail Eggs', 'Bacon Strips',
  'Rohu Fish', 'Tilapia'
];

const List<String> nonVegRestaurants = [
  'Meaty Bites', 'Grill House', 'KFC Style Hub', 'Non-Veg Express',
  'BBQ Nation', 'Spicy Grill', 'Chicken Town', 'Andhra Non-Veg Meals',
  'Hyderabadi Biryani', 'Seafood Shack', 'Tandoori Nights',
  'Fish Fry Corner', 'Nawabi Kebabs', 'Butter Chicken Point',
  'Biryani Blues', 'Mutton Masala House', 'Gravy Junction',
  'Chettinad Corner', 'Egg Curry Café', 'Mughlai Express'
];