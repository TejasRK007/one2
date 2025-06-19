import 'package:flutter/material.dart';
import 'upi_payment_page.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  String searchQuery = '';
  final Map<String, bool> selectedItems = {};

  // At least 80 food options (veg, non-veg, others)
  final List<FoodItem> allFoodItems = [
    // Veg
    FoodItem('Paneer Butter Masala', 180, 'assets/food/paneer.png', 'Veg'),
    FoodItem('Dal Makhani', 140, 'assets/food/dal.png', 'Veg'),
    FoodItem('Aloo Gobi', 120, 'assets/food/aloo_gobi.png', 'Veg'),
    FoodItem('Palak Paneer', 160, 'assets/food/palak_paneer.png', 'Veg'),
    FoodItem('Chole Bhature', 110, 'assets/food/chole_bhature.png', 'Veg'),
    FoodItem('Rajma Chawal', 100, 'assets/food/rajma.png', 'Veg'),
    FoodItem('Veg Biryani', 130, 'assets/food/veg_biryani.png', 'Veg'),
    FoodItem('Masala Dosa', 90, 'assets/food/dosa.png', 'Veg'),
    FoodItem('Idli Sambar', 70, 'assets/food/idli.png', 'Veg'),
    FoodItem('Pav Bhaji', 80, 'assets/food/pav_bhaji.png', 'Veg'),
    FoodItem('Samosa', 20, 'assets/food/samosa.png', 'Veg'),
    FoodItem('Dhokla', 40, 'assets/food/dhokla.png', 'Veg'),
    FoodItem('Kadhai Mushroom', 170, 'assets/food/mushroom.png', 'Veg'),
    FoodItem('Baingan Bharta', 110, 'assets/food/baingan.png', 'Veg'),
    FoodItem('Bhindi Masala', 100, 'assets/food/bhindi.png', 'Veg'),
    FoodItem('Mix Veg', 120, 'assets/food/mix_veg.png', 'Veg'),
    FoodItem('Paneer Tikka', 150, 'assets/food/paneer_tikka.png', 'Veg'),
    FoodItem('Malai Kofta', 160, 'assets/food/kofta.png', 'Veg'),
    FoodItem('Veg Pulao', 110, 'assets/food/pulao.png', 'Veg'),
    FoodItem('Gobi Manchurian', 130, 'assets/food/gobi.png', 'Veg'),
    FoodItem('Corn Soup', 80, 'assets/food/corn_soup.png', 'Veg'),
    FoodItem('Veg Momos', 60, 'assets/food/momos.png', 'Veg'),
    FoodItem('Paneer Roll', 90, 'assets/food/paneer_roll.png', 'Veg'),
    FoodItem('Veg Burger', 70, 'assets/food/burger.png', 'Veg'),
    FoodItem('French Fries', 60, 'assets/food/fries.png', 'Veg'),
    FoodItem('Spring Roll', 80, 'assets/food/spring_roll.png', 'Veg'),
    FoodItem('Veg Pizza', 150, 'assets/food/pizza.png', 'Veg'),
    FoodItem('Hakka Noodles', 120, 'assets/food/noodles.png', 'Veg'),
    FoodItem('Paneer Frankie', 100, 'assets/food/frankie.png', 'Veg'),
    FoodItem('Veg Sandwich', 60, 'assets/food/sandwich.png', 'Veg'),
    FoodItem('Chana Masala', 110, 'assets/food/chana.png', 'Veg'),
    FoodItem('Aloo Paratha', 50, 'assets/food/paratha.png', 'Veg'),
    FoodItem('Kathi Roll', 90, 'assets/food/kathi_roll.png', 'Veg'),
    FoodItem('Paneer Pakoda', 70, 'assets/food/pakoda.png', 'Veg'),
    FoodItem('Veg Cutlet', 60, 'assets/food/cutlet.png', 'Veg'),
    FoodItem('Daal Tadka', 100, 'assets/food/daal_tadka.png', 'Veg'),
    FoodItem('Paneer Bhurji', 120, 'assets/food/bhurji.png', 'Veg'),
    FoodItem('Veg Thali', 180, 'assets/food/thali.png', 'Veg'),
    FoodItem('Paneer Pizza', 170, 'assets/food/paneer_pizza.png', 'Veg'),
    FoodItem('Veg Fried Rice', 110, 'assets/food/fried_rice.png', 'Veg'),
    // Non-Veg
    FoodItem('Chicken Biryani', 200, 'assets/food/chicken_biryani.png', 'Non-Veg'),
    FoodItem('Butter Chicken', 220, 'assets/food/butter_chicken.png', 'Non-Veg'),
    FoodItem('Egg Curry', 120, 'assets/food/egg_curry.png', 'Non-Veg'),
    FoodItem('Fish Curry', 180, 'assets/food/fish_curry.png', 'Non-Veg'),
    FoodItem('Mutton Rogan Josh', 250, 'assets/food/rogan_josh.png', 'Non-Veg'),
    FoodItem('Chicken Tikka', 180, 'assets/food/chicken_tikka.png', 'Non-Veg'),
    FoodItem('Prawn Masala', 230, 'assets/food/prawn.png', 'Non-Veg'),
    FoodItem('Chicken 65', 160, 'assets/food/chicken65.png', 'Non-Veg'),
    FoodItem('Fish Fry', 170, 'assets/food/fish_fry.png', 'Non-Veg'),
    FoodItem('Egg Bhurji', 90, 'assets/food/egg_bhurji.png', 'Non-Veg'),
    FoodItem('Chicken Lollipop', 150, 'assets/food/lollipop.png', 'Non-Veg'),
    FoodItem('Mutton Korma', 240, 'assets/food/korma.png', 'Non-Veg'),
    FoodItem('Chicken Shawarma', 130, 'assets/food/shawarma.png', 'Non-Veg'),
    FoodItem('Fish Biryani', 210, 'assets/food/fish_biryani.png', 'Non-Veg'),
    FoodItem('Egg Roll', 80, 'assets/food/egg_roll.png', 'Non-Veg'),
    FoodItem('Chicken Burger', 120, 'assets/food/chicken_burger.png', 'Non-Veg'),
    FoodItem('Chicken Pizza', 170, 'assets/food/chicken_pizza.png', 'Non-Veg'),
    FoodItem('Mutton Seekh Kebab', 200, 'assets/food/seekh_kebab.png', 'Non-Veg'),
    FoodItem('Fish Pakora', 140, 'assets/food/fish_pakora.png', 'Non-Veg'),
    FoodItem('Chicken Momos', 100, 'assets/food/chicken_momos.png', 'Non-Veg'),
    FoodItem('Egg Fried Rice', 110, 'assets/food/egg_fried_rice.png', 'Non-Veg'),
    FoodItem('Chicken Noodles', 130, 'assets/food/chicken_noodles.png', 'Non-Veg'),
    FoodItem('Fish Fingers', 120, 'assets/food/fish_fingers.png', 'Non-Veg'),
    FoodItem('Chicken Curry', 160, 'assets/food/chicken_curry.png', 'Non-Veg'),
    FoodItem('Mutton Biryani', 240, 'assets/food/mutton_biryani.png', 'Non-Veg'),
    FoodItem('Egg Sandwich', 60, 'assets/food/egg_sandwich.png', 'Non-Veg'),
    FoodItem('Chicken Frankie', 110, 'assets/food/chicken_frankie.png', 'Non-Veg'),
    FoodItem('Fish Thali', 200, 'assets/food/fish_thali.png', 'Non-Veg'),
    FoodItem('Chicken Thali', 180, 'assets/food/chicken_thali.png', 'Non-Veg'),
    FoodItem('Egg Paratha', 70, 'assets/food/egg_paratha.png', 'Non-Veg'),
    FoodItem('Chicken Pakoda', 90, 'assets/food/chicken_pakoda.png', 'Non-Veg'),
    FoodItem('Fish Curry Rice', 160, 'assets/food/fish_curry_rice.png', 'Non-Veg'),
    FoodItem('Chicken Soup', 80, 'assets/food/chicken_soup.png', 'Non-Veg'),
    FoodItem('Egg Bhurji Pav', 60, 'assets/food/egg_bhurji_pav.png', 'Non-Veg'),
    FoodItem('Chicken Wings', 140, 'assets/food/chicken_wings.png', 'Non-Veg'),
    FoodItem('Fish Cutlet', 110, 'assets/food/fish_cutlet.png', 'Non-Veg'),
    FoodItem('Chicken Kathi Roll', 120, 'assets/food/chicken_kathi_roll.png', 'Non-Veg'),
    FoodItem('Egg Curry Rice', 90, 'assets/food/egg_curry_rice.png', 'Non-Veg'),
    // Others (snacks, desserts, drinks)
    FoodItem('Gulab Jamun', 50, 'assets/food/gulab_jamun.png', 'Dessert'),
    FoodItem('Rasgulla', 45, 'assets/food/rasgulla.png', 'Dessert'),
    FoodItem('Ice Cream', 60, 'assets/food/ice_cream.png', 'Dessert'),
    FoodItem('Brownie', 70, 'assets/food/brownie.png', 'Dessert'),
    FoodItem('Lassi', 40, 'assets/food/lassi.png', 'Drink'),
    FoodItem('Cold Coffee', 60, 'assets/food/cold_coffee.png', 'Drink'),
    FoodItem('Mango Shake', 50, 'assets/food/mango_shake.png', 'Drink'),
    FoodItem('Masala Chai', 20, 'assets/food/chai.png', 'Drink'),
    FoodItem('Soda', 25, 'assets/food/soda.png', 'Drink'),
    FoodItem('Fruit Salad', 60, 'assets/food/fruit_salad.png', 'Dessert'),
    FoodItem('Chocolate Cake', 80, 'assets/food/chocolate_cake.png', 'Dessert'),
    FoodItem('Pani Puri', 30, 'assets/food/pani_puri.png', 'Snack'),
    FoodItem('Bhel Puri', 25, 'assets/food/bhel_puri.png', 'Snack'),
    FoodItem('Vada Pav', 20, 'assets/food/vada_pav.png', 'Snack'),
    FoodItem('Dabeli', 25, 'assets/food/dabeli.png', 'Snack'),
    FoodItem('Schezwan Noodles', 110, 'assets/food/schezwan_noodles.png', 'Veg'),
    FoodItem('Veg Manchurian', 120, 'assets/food/veg_manchurian.png', 'Veg'),
    FoodItem('Chicken Manchurian', 140, 'assets/food/chicken_manchurian.png', 'Non-Veg'),
  ];

  double get total {
    double sum = 0.0;
    selectedItems.forEach((name, selected) {
      if (selected) {
        sum += allFoodItems.firstWhere((f) => f.name == name).price;
      }
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    // Filter food items by search
    final filtered = allFoodItems.where((item) =>
      searchQuery.isEmpty ||
      item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      item.category.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    // Group by category
    final categories = filtered.map((f) => f.category).toSet().toList();

    final selectedFood = allFoodItems.where((f) => selectedItems[f.name] ?? false).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: selectedFood.isEmpty ? null : () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => _buildCartSheet(context, selectedFood),
                  );
                },
              ),
              if (selectedFood.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      selectedFood.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food, e.g. Biryani, Paneer, Dessert...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final cat in categories)
                  _buildCategorySection(cat, filtered.where((f) => f.category == cat).toList()),
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Pay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedFood.isEmpty ? null : () {
                    // Navigate to common payment page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UPIPaymentPage(
                          cardId: 'FOODCART',
                          scannedData: selectedFood.map((f) => f.name).join(', '),
                          timestamp: DateTime.now().toString(),
                          username: 'DemoUser', // Replace with real user info
                          email: 'demo@example.com',
                          phone: '1234567890',
                          password: 'demo123',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<FoodItem> items) {
    final color = _categoryColor(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(_categoryIcon(category), color: color),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              final selected = selectedItems[item.name] ?? false;
              return _buildFoodCard(item, selected, color);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(FoodItem item, bool selected, Color color) {
    return Container(
      width: 160,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: selected ? color.withOpacity(0.12) : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => selectedItems[item.name] = !selected),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.imageAsset,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(_categoryIcon(item.category), color: color, size: 48),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text('₹${item.price}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                const Spacer(),
                Icon(
                  selected ? Icons.check_circle : Icons.add_circle_outline,
                  color: selected ? color : Colors.grey,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartSheet(BuildContext context, List<FoodItem> selectedFood) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...selectedFood.map((f) => ListTile(
                leading: Image.asset(f.imageAsset, width: 36, height: 36, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.fastfood)),
                title: Text(f.name),
                trailing: Text('₹${f.price}'),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹${selectedFood.fold(0.0, (sum, f) => sum + f.price).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Proceed to Pay'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UPIPaymentPage(
                    cardId: 'FOODCART',
                    scannedData: selectedFood.map((f) => f.name).join(', '),
                    timestamp: DateTime.now().toString(),
                    username: 'DemoUser', // Replace with real user info
                    email: 'demo@example.com',
                    phone: '1234567890',
                    password: 'demo123',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Veg': return Icons.eco;
      case 'Non-Veg': return Icons.set_meal;
      case 'Dessert': return Icons.icecream;
      case 'Drink': return Icons.local_drink;
      case 'Snack': return Icons.fastfood;
      default: return Icons.restaurant_menu;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Veg': return Colors.green;
      case 'Non-Veg': return Colors.red;
      case 'Dessert': return Colors.pink;
      case 'Drink': return Colors.blue;
      case 'Snack': return Colors.orange;
      default: return Colors.deepOrange;
    }
  }
}

class FoodItem {
  final String name;
  final double price;
  final String imageAsset;
  final String category;
  FoodItem(this.name, this.price, this.imageAsset, this.category);
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FoodPage(),
  ));
}