import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upi_payment_page.dart'; // Import your UPI Payment Page

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool _isPermissionGranted = false;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  void _onQRViewCreated(BarcodeCapture capture) async {
    if (_isScanned) return;
    _isScanned = true;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue ?? "No data";

    print('🔍 Scanned: $code');

    if (code.startsWith('upi:')) {
      // UPI QR detected -> Navigate to UPI Payment Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UPIPaymentPage(upiUrl: code),
        ),
      );
    } else {
      // Normal URL or Text -> Show and launch
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Scanned: $code')),
      );
      await _tryLaunch(code);
    }

    // Allow scanning again after few seconds
    await Future.delayed(const Duration(seconds: 3));
    _isScanned = false;
  }

  Future<void> _tryLaunch(String code) async {
    String url = code.trim();

    if (!url.startsWith('http') &&
        !url.startsWith('upi:') &&
        !url.startsWith('intent:')) {
      url = 'https://$url';
    }

    Uri? uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('❌ Launch failed: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Could not launch: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner")),
      body: _isPermissionGranted
          ? Stack(
        children: [
          MobileScanner(onDetect: _onQRViewCreated),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      )
          : const Center(child: Text("Camera permission not granted")),
    );
  }
}










