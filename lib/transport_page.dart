import 'package:flutter/material.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  String selectedFrom = 'Mumbai';
  String selectedTo = 'Delhi';

  final List<String> metroCities = [
    'Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Hyderabad', 'Kolkata'
  ];

  @override
  Widget build(BuildContext context) {
    final List<TransportInfo> filteredOptions = allTransportOptions.where((t) =>
    t.from == selectedFrom && t.to == selectedTo).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Transport Services")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "From",
                    selectedFrom,
                        (val) => setState(() => selectedFrom = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    "To",
                    selectedTo,
                        (val) => setState(() => selectedTo = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredOptions.isEmpty
                  ? const Center(child: Text("No transport options available."))
                  : ListView.builder(
                itemCount: filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = filteredOptions[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(option.icon, color: Colors.teal),
                      title: Text(option.name),
                      subtitle: Text("From: ${option.from}  ➜  To: ${option.to}"),
                      trailing: Text(option.fare, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value.isNotEmpty ? value : null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: metroCities
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class TransportInfo {
  final String name;
  final String from;
  final String to;
  final String fare;
  final IconData icon;

  TransportInfo({
    required this.name,
    required this.from,
    required this.to,
    required this.fare,
    required this.icon,
  });
}

// 🚄 Dummy Data for Metro Cities Only
final List<TransportInfo> allTransportOptions = [
  // 🚇 Metro
  TransportInfo(name: 'Delhi Metro – Blue Line', from: 'Delhi', to: 'Delhi', fare: '₹30', icon: Icons.tram),
  TransportInfo(name: 'Bangalore Metro – Purple Line', from: 'Bengaluru', to: 'Bengaluru', fare: '₹25', icon: Icons.tram),
  TransportInfo(name: 'Mumbai Metro – Line 1', from: 'Mumbai', to: 'Mumbai', fare: '₹40', icon: Icons.tram),
  TransportInfo(name: 'Hyderabad Metro – Red Line', from: 'Hyderabad', to: 'Hyderabad', fare: '₹35', icon: Icons.tram),
  TransportInfo(name: 'Chennai Metro – Green Line', from: 'Chennai', to: 'Chennai', fare: '₹50', icon: Icons.tram),
  TransportInfo(name: 'Kolkata Metro – NS Line', from: 'Kolkata', to: 'Kolkata', fare: '₹20', icon: Icons.tram),

  // 🚉 Trains
  TransportInfo(name: 'Chennai Express', from: 'Chennai', to: 'Mumbai', fare: '₹750', icon: Icons.train),
  TransportInfo(name: 'Rajdhani Express', from: 'Mumbai', to: 'Delhi', fare: '₹2200', icon: Icons.train),
  TransportInfo(name: 'Duronto Express', from: 'Kolkata', to: 'Hyderabad', fare: '₹1600', icon: Icons.train),
  TransportInfo(name: 'Yeshvantpur Exp', from: 'Bengaluru', to: 'Chennai', fare: '₹600', icon: Icons.train),
  TransportInfo(name: 'Shatabdi Express', from: 'Delhi', to: 'Bengaluru', fare: '₹1800', icon: Icons.train),

  // ✈️ Flights
  TransportInfo(name: 'IndiGo 6E-445', from: 'Mumbai', to: 'Hyderabad', fare: '₹3500', icon: Icons.flight),
  TransportInfo(name: 'Air India AI-202', from: 'Delhi', to: 'Kolkata', fare: '₹4000', icon: Icons.flight),
  TransportInfo(name: 'SpiceJet SG-89', from: 'Bengaluru', to: 'Chennai', fare: '₹2800', icon: Icons.flight),
  TransportInfo(name: 'Vistara UK-107', from: 'Mumbai', to: 'Delhi', fare: '₹4500', icon: Icons.flight),
  TransportInfo(name: 'Go First G8-121', from: 'Hyderabad', to: 'Bengaluru', fare: '₹3200', icon: Icons.flight),
];