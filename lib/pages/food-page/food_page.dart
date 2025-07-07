import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedFood = 'Dry Kibble';
  double _quantity = 100;
  TimeOfDay _time = TimeOfDay.now();

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal logged (placeholder).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _time.format(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFood,
              items: const [
                DropdownMenuItem(value: 'Dry Kibble', child: Text('Dry Kibble')),
                DropdownMenuItem(value: 'Wet Food', child: Text('Wet Food')),
                DropdownMenuItem(value: 'Treats', child: Text('Treats')),
              ],
              onChanged: (val) => setState(() => _selectedFood = val!),
              decoration: const InputDecoration(
                labelText: 'Food Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _quantity.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quantity (grams)',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                final num? qty = num.tryParse(val ?? '');
                if (qty == null || qty <= 0) return 'Enter a valid quantity';
                return null;
              },
              onChanged: (val) {
                final num? qty = num.tryParse(val);
                if (qty != null) {
                  _quantity = qty.toDouble();
                }
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(timeLabel),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Log Meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}