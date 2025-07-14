import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _scanned = false;
  String? _productName;
  String? _error;
  final TextEditingController _controller = TextEditingController();

  Future<void> _fetchProductName(String barcode) async {
    setState(() {
      _productName = null;
      _error = null;
    });

    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data['status'] == 1) {
        final name = data['product']['product_name'] ?? 'Unknown Product';
        setState(() {
          _productName = name;
          _controller.text = name;
        });
      } else {
        setState(() => _error = 'Product not found.');
      }
    } catch (e) {
      setState(() => _error = 'Error fetching product.');
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;
    _scanned = true;
    _fetchProductName(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              onDetect: _onBarcodeDetected,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _productName != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Product Detected:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          onChanged: (val) => _productName = val,
                          decoration: const InputDecoration(
                            labelText: 'Edit product name (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, _productName),
                              child: const Text('Use'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        )
                      ],
                    )
                  : _error != null
                      ? Column(
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() => _scanned = false),
                              child: const Text('Try Again'),
                            )
                          ],
                        )
                      : const Center(child: Text('Scanning...')),
            ),
          )
        ],
      ),
    );
  }
}
