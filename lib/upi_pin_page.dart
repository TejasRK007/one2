import 'package:flutter/material.dart';

class UpiPinPage extends StatefulWidget {
  final String? currentPin;
  final Function(String) onPinSet;

  const UpiPinPage({super.key, this.currentPin, required this.onPinSet});

  @override
  _UpiPinPageState createState() => _UpiPinPageState();
}

class _UpiPinPageState extends State<UpiPinPage> {
  final _formKey = GlobalKey<FormState>();
  String? _oldPin;
  final _newPinController = TextEditingController();
  String? _confirmPin;

  @override
  void dispose() {
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentPin != null ? 'Reset UPI PIN' : 'Set UPI PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.currentPin != null)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Old PIN'),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old PIN';
                    }
                    if (value != widget.currentPin) {
                      return 'Incorrect old PIN';
                    }
                    return null;
                  },
                  onSaved: (value) => _oldPin = value,
                ),
              TextFormField(
                controller: _newPinController,
                decoration: const InputDecoration(labelText: 'New PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 4) {
                    return 'PIN must be 4 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirm New PIN'),
                obscureText: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new PIN';
                  }
                  if (_newPinController.text != value) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onPinSet(_newPinController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UPI PIN has been set successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 