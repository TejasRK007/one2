import 'package:flutter/material.dart';
import 'transport_fare_payment_page.dart';
import 'package:flutter/services.dart';
import 'upi_payment_page.dart';
import 'metro_page.dart';

class TransportPage extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String password;
  final String? upiPin;
  final void Function(String)? onPinSet;

  const TransportPage({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.upiPin,
    this.onPinSet,
  });

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  String selectedFrom = 'Mumbai';
  String selectedTo = 'Delhi';
  String searchQuery = '';

  // Expanded list of major Indian cities
  final List<String> allCities = [
    'Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Hyderabad', 'Kolkata',
    'Pune', 'Ahmedabad', 'Jaipur', 'Lucknow', 'Patna', 'Indore', 'Bhopal',
    'Nagpur', 'Chandigarh', 'Coimbatore', 'Kochi', 'Visakhapatnam', 'Goa',
    'Guwahati', 'Surat', 'Kanpur', 'Varanasi', 'Agra', 'Ludhiana', 'Nashik',
  ];

  final List<String> metroBusCities = [
    'Bengaluru', 'Chennai', 'Mumbai', 'Kolkata', 'Kochi'
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic: always show Train and Flight, add Metro and Bus if either city is in metroBusCities
    final fromSpecial = metroBusCities.contains(selectedFrom);
    final toSpecial = metroBusCities.contains(selectedTo);
    final showMetroBus = fromSpecial || toSpecial;

    // Filtered options
    final filteredOptions = allTransportOptions.where((t) {
      final matchesRoute = (t.from == selectedFrom && t.to == selectedTo);
      final isTrainOrFlight = t.type == 'Train' || t.type == 'Flight';
      final isMetroOrBus = t.type == 'Metro' || t.type == 'Bus';
      final matchesSearch = searchQuery.isEmpty ||
        t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        t.type.toLowerCase().contains(searchQuery.toLowerCase());
      if (isTrainOrFlight && matchesSearch) {
        // Always show train/flight for any route
        return (t.from == selectedFrom && t.to == selectedTo) || (t.type == 'Train' || t.type == 'Flight');
      }
      if (isMetroOrBus && showMetroBus && matchesSearch) {
        // Show metro/bus if either city is special
        return (t.from == selectedFrom || t.to == selectedTo) && (t.type == 'Metro' || t.type == 'Bus');
      }
      // Other types (Cab, Auto) only if route matches
      return matchesRoute && matchesSearch;
    }).toList();

    // Group by type
    final Map<String, List<TransportInfo>> grouped = {};
    for (final t in filteredOptions) {
      grouped.putIfAbsent(t.type, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transport Services"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Search bar at the top
            TextField(
              decoration: InputDecoration(
                hintText: 'Search transport, e.g. Metro, Rajdhani... ',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 16),
            // 2. City selection dropdowns in their own Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdown("From", selectedFrom, (val) => setState(() => selectedFrom = val!)),
                    const SizedBox(height: 24),
                    _buildDropdown("To", selectedTo, (val) => setState(() => selectedTo = val!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 4. Transport options sections
            if (grouped.isEmpty)
              const Center(child: Text("No transport options available for this route.")),
            for (final type in grouped.keys)
              _buildTransportSection(type, grouped[type]!),
            const SizedBox(height: 24),
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
          value: value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: allCities
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTransportSection(String type, List<TransportInfo> options) {
    final icon = _typeIcon(type);
    final color = _typeColor(type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                padding: const EdgeInsets.only(right: 16),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildTransportCard(option, color),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransportCard(TransportInfo option, Color color) {
    return Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 220),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogo(option),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(child: Text('From: ${option.from}', style: const TextStyle(fontSize: 14))),
              Flexible(child: Text('To: ${option.to}', style: const TextStyle(fontSize: 14))),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(option.fare, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      final fareAmount = double.tryParse(option.fare.replaceAll('₹', '').trim());
                      if (fareAmount == null) return; // Fare couldn't be parsed

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransportFarePaymentPage(
                            amount: fareAmount,
                            cardId: 'TRANSPORT',
                            scannedData: option.name,
                            timestamp: DateTime.now().toString(),
                            username: widget.username,
                            email: widget.email,
                            phone: widget.phone,
                            password: widget.password,
                            upiPin: widget.upiPin,
                            onPinSet: widget.onPinSet,
                          ),
                        ),
                      );
                    },
                    child: const Text("Pay"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(TransportInfo option) {
    // Try to use asset image if available, else fallback to icon
    final assetName = option.logoAsset;
    if (assetName != null && assetName.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetName,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(option.icon, color: _typeColor(option.type), size: 32),
        ),
      );
    }
    return Icon(option.icon, color: _typeColor(option.type), size: 32);
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Metro': return Icons.tram;
      case 'Train': return Icons.train;
      case 'Flight': return Icons.flight;
      case 'Bus': return Icons.directions_bus;
      case 'Cab': return Icons.local_taxi;
      case 'Auto': return Icons.electric_rickshaw;
      default: return Icons.directions_transit;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Metro': return Colors.deepPurple;
      case 'Train': return Colors.teal;
      case 'Flight': return Colors.indigo;
      case 'Bus': return Colors.orange;
      case 'Cab': return Colors.blueGrey;
      case 'Auto': return Colors.green;
      default: return Colors.grey;
    }
  }
}

class TransportInfo {
  final String name;
  final String from;
  final String to;
  final String fare;
  final IconData icon;
  final String type; // Metro, Train, Flight, Bus, Cab, Auto
  final String? logoAsset; // Path to logo asset

  TransportInfo({
    required this.name,
    required this.from,
    required this.to,
    required this.fare,
    required this.icon,
    required this.type,
    this.logoAsset,
  });
}

final List<TransportInfo> allTransportOptions = [
  // Metro (cheapest)
  TransportInfo(name: 'Delhi Metro – Blue Line', from: 'Delhi', to: 'Delhi', fare: '₹30', icon: Icons.tram, type: 'Metro'),
  TransportInfo(name: 'Bangalore Metro – Purple Line', from: 'Bengaluru', to: 'Bengaluru', fare: '₹25', icon: Icons.tram, type: 'Metro'),
  TransportInfo(name: 'Mumbai Metro – Line 1', from: 'Mumbai', to: 'Mumbai', fare: '₹35', icon: Icons.tram, type: 'Metro'),
  TransportInfo(name: 'Hyderabad Metro – Red Line', from: 'Hyderabad', to: 'Hyderabad', fare: '₹28', icon: Icons.tram, type: 'Metro'),
  TransportInfo(name: 'Chennai Metro – Green Line', from: 'Chennai', to: 'Chennai', fare: '₹32', icon: Icons.tram, type: 'Metro'),
  TransportInfo(name: 'Kolkata Metro – NS Line', from: 'Kolkata', to: 'Kolkata', fare: '₹22', icon: Icons.tram, type: 'Metro'),
  // Train (mid-high)
  TransportInfo(name: 'Chennai Express', from: 'Chennai', to: 'Mumbai', fare: '₹1200', icon: Icons.train, type: 'Train'),
  TransportInfo(name: 'Rajdhani Express', from: 'Mumbai', to: 'Delhi', fare: '₹2500', icon: Icons.train, type: 'Train'),
  TransportInfo(name: 'Duronto Express', from: 'Kolkata', to: 'Hyderabad', fare: '₹1800', icon: Icons.train, type: 'Train'),
  TransportInfo(name: 'Yeshvantpur Exp', from: 'Bengaluru', to: 'Chennai', fare: '₹950', icon: Icons.train, type: 'Train'),
  TransportInfo(name: 'Shatabdi Express', from: 'Delhi', to: 'Bengaluru', fare: '₹2100', icon: Icons.train, type: 'Train'),
  // Flight (most expensive)
  TransportInfo(name: 'IndiGo 6E-445', from: 'Mumbai', to: 'Hyderabad', fare: '₹5200', icon: Icons.flight, type: 'Flight'),
  TransportInfo(name: 'Air India AI-202', from: 'Delhi', to: 'Kolkata', fare: '₹6700', icon: Icons.flight, type: 'Flight'),
  TransportInfo(name: 'SpiceJet SG-89', from: 'Bengaluru', to: 'Chennai', fare: '₹4800', icon: Icons.flight, type: 'Flight'),
  TransportInfo(name: 'Vistara UK-107', from: 'Mumbai', to: 'Delhi', fare: '₹7500', icon: Icons.flight, type: 'Flight'),
  TransportInfo(name: 'Go First G8-121', from: 'Hyderabad', to: 'Bengaluru', fare: '₹4100', icon: Icons.flight, type: 'Flight'),
  // Bus (cheap)
  TransportInfo(name: 'MSRTC Shivneri', from: 'Mumbai', to: 'Pune', fare: '₹350', icon: Icons.directions_bus, type: 'Bus'),
  TransportInfo(name: 'BMTC Volvo', from: 'Bengaluru', to: 'Mysuru', fare: '₹220', icon: Icons.directions_bus, type: 'Bus'),
  TransportInfo(name: 'TSRTC Garuda', from: 'Hyderabad', to: 'Vijayawada', fare: '₹280', icon: Icons.directions_bus, type: 'Bus'),
  TransportInfo(name: 'APSRTC Super Luxury', from: 'Vijayawada', to: 'Visakhapatnam', fare: '₹400', icon: Icons.directions_bus, type: 'Bus'),
  TransportInfo(name: 'WBTC AC Bus', from: 'Kolkata', to: 'Durgapur', fare: '₹320', icon: Icons.directions_bus, type: 'Bus'),
  // Cab (expensive, but less than flight)
  TransportInfo(name: 'Ola Mini', from: 'Mumbai', to: 'Nashik', fare: '₹2600', icon: Icons.local_taxi, type: 'Cab'),
  TransportInfo(name: 'Uber Premier', from: 'Delhi', to: 'Agra', fare: '₹3100', icon: Icons.local_taxi, type: 'Cab'),
  TransportInfo(name: 'Meru Cab', from: 'Bengaluru', to: 'Coimbatore', fare: '₹3900', icon: Icons.local_taxi, type: 'Cab'),
  // Auto (cheapest local)
  TransportInfo(name: 'Auto Rickshaw', from: 'Mumbai', to: 'Mumbai', fare: '₹90', icon: Icons.electric_rickshaw, type: 'Auto'),
  TransportInfo(name: 'Auto Rickshaw', from: 'Delhi', to: 'Delhi', fare: '₹80', icon: Icons.electric_rickshaw, type: 'Auto'),
  TransportInfo(name: 'Auto Rickshaw', from: 'Chennai', to: 'Chennai', fare: '₹70', icon: Icons.electric_rickshaw, type: 'Auto'),
];
