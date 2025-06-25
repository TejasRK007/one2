import 'package:flutter/material.dart';
import 'transport_fare_payment_page.dart';

class MetroPage extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String password;

  const MetroPage({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  _MetroPageState createState() => _MetroPageState();
}

class _MetroPageState extends State<MetroPage> {
  String? _fromStation;
  String? _toStation;
  double? _fare;

  final List<String> _greenLine = [
    'Nagasandra', 'Dasarahalli', 'Jalahalli', 'Peenya Industry', 'Peenya', 'Goraguntepalya', 'Yeshwanthpur', 'Sandal Soap Factory', 'Mahalakshmi', 'Rajajinagar', 'Kuvempu Road', 'Srirampura', 'Sampige Road', 'Nadaprabhu Kempegowda Station, Majestic', 'Chickpet', 'Krishna Rajendra Market', 'National College', 'Lalbagh', 'South End Circle', 'Jayanagar', 'RV Road', 'Banashankari', 'Jayaprakash Nagar', 'Yelachenahalli', 'Konankunte Cross', 'Doddakallasandra', 'Vajarahalli', 'Talaghattapura', 'Silk Institute'
  ];

  final List<String> _purpleLine = [
    'Whitefield (Kadugodi)', 'Hopefarm Channasandra', 'Sri Sathya Sai Hospital', 'Nallurhalli', 'Kundalahalli', 'Seetharam Palya', 'Hoodi', 'Garudacharapalya', 'Singayyanapalya', 'KR Puram', 'Baiyappanahalli', 'Swami Vivekananda Road', 'Indiranagar', 'Halasuru', 'Trinity', 'Mahatma Gandhi Road', 'Cubbon Park', 'Dr. B.R. Ambedkar Station, Vidhana Soudha', 'Sir M. Visvesvaraya Station, Central College', 'Nadaprabhu Kempegowda Station, Majestic', 'KSR Railway Station', 'Magadi Road', 'Hosahalli', 'Vijayanagar', 'Attiguppe', 'Deepanjali Nagar', 'Mysore Road', 'Nayandahalli', 'Rajarajeshwari Nagar', 'Jnana Bharathi', 'Pattanagere', 'Kengeri Bus Terminal', 'Kengeri'
  ];

  late final List<String> _allStations;

  @override
  void initState() {
    super.initState();
    _allStations = [..._greenLine, ..._purpleLine]..sort();
  }

  void _calculateFare() {
    if (_fromStation == null || _toStation == null) return;
    if (_fromStation == _toStation) {
      setState(() => _fare = 0);
      return;
    }

    // Dummy fare calculation logic
    final fromIndex = _allStations.indexOf(_fromStation!);
    final toIndex = _allStations.indexOf(_toStation!);
    final distance = (fromIndex - toIndex).abs();
    setState(() => _fare = (distance * 2.5) + 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metro Ticketing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _fromStation,
              items: _allStations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() {
                _fromStation = val;
                _calculateFare();
              }),
              decoration: const InputDecoration(labelText: 'From Station'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _toStation,
              items: _allStations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() {
                _toStation = val;
                _calculateFare();
              }),
              decoration: const InputDecoration(labelText: 'To Station'),
            ),
            const SizedBox(height: 20),
            if (_fare != null)
              Text('Fare: ₹${_fare!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_fare != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransportFarePaymentPage(
                        amount: _fare!,
                        cardId: 'METRO',
                        scannedData: 'Metro: $_fromStation to $_toStation',
                        timestamp: DateTime.now().toString(),
                        username: widget.username,
                        email: widget.email,
                        phone: widget.phone,
                        password: widget.password,
                      ),
                    ),
                  );
                },
                child: const Text('Pay Fare'),
              ),
          ],
        ),
      ),
    );
  }
} 