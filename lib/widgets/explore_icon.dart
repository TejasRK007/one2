import 'package:flutter/material.dart';

class ExploreIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const ExploreIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.indigo.shade100,
          child: Icon(icon, size: 28, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
