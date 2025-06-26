import 'package:flutter/material.dart';

class UpiPinDialog extends StatefulWidget {
  final String? currentPin;
  final void Function(String) onPinVerified;
  final void Function(String)? onPinSet;

  const UpiPinDialog({
    super.key,
    required this.currentPin,
    required this.onPinVerified,
    this.onPinSet,
  });

  @override
  State<UpiPinDialog> createState() => _UpiPinDialogState();
}

class _UpiPinDialogState extends State<UpiPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _errorText;
  bool _isSettingPin = false;

  @override
  void initState() {
    super.initState();
    _isSettingPin = widget.currentPin == null;
  }

  void _handleSubmit() {
    final pin = _pinController.text.trim();
    if (_isSettingPin) {
      final confirmPin = _confirmPinController.text.trim();
      if (pin.length < 4) {
        setState(() => _errorText = 'PIN must be at least 4 digits');
        return;
      }
      if (pin != confirmPin) {
        setState(() => _errorText = 'PINs do not match');
        return;
      }
      widget.onPinSet?.call(pin);
      if (mounted) Navigator.of(context).pop(true);
    } else {
      if (pin == widget.currentPin) {
        widget.onPinVerified(pin);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() => _errorText = 'Incorrect PIN');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isSettingPin ? 'Set UPI PIN' : 'Enter UPI PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'UPI PIN',
              counterText: '',
              errorText: _errorText,
            ),
          ),
          if (_isSettingPin)
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                counterText: '',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () { if (mounted) Navigator.of(context).pop(false); },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(_isSettingPin ? 'Set PIN' : 'Verify'),
        ),
      ],
    );
  }
} 