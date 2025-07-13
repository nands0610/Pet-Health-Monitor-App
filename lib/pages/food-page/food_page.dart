import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedFood = 'Dry Kibble - Royal Canin - Dry';
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
        const SnackBar(content: Text('Meal logged successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _time.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Tracker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Today, July 13', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: 0.6,
                                strokeWidth: 6,
                                backgroundColor: Colors.grey[200],
                                color: Colors.teal,
                              ),
                            ),
                            const Text('60%', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        const Text('1,250 cal\n60% of daily goal', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text('Analytics'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('Log a Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text('Select from your saved foods or add new ones'),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedFood,
                            items: const [
                              DropdownMenuItem(value: 'Dry Kibble - Royal Canin - Dry', child: Text('Dry Kibble - Royal Canin - Dry')),
                              DropdownMenuItem(value: 'Wet Food - Hill\'s Science - Wet', child: Text('Wet Food - Hill\'s Science - Wet')),
                              DropdownMenuItem(value: 'Treats - Blue Buffalo - Snack', child: Text('Treats - Blue Buffalo - Snack')),
                            ],
                            onChanged: (val) => setState(() => _selectedFood = val!),
                            decoration: const InputDecoration(
                              labelText: 'Food (Name - Brand - Type)',
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
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Log Meal'),
                              onPressed: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
