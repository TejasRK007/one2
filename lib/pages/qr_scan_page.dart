import 'package:flutter/material.dart';

class QRScanPage extends StatelessWidget {
  const QRScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scan")),
      body: const Center(child: Text("Scan QR to Pay or Access")),
    );
  }
}
