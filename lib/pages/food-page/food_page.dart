import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final List<Map<String, String>> _recentMeals = [
    {
      'title': 'Premium Dry Food - 420 cal - 1.5 cups',
      'time': '1:30 PM'
    },
    {
      'title': 'Wet Food - 380 cal - 1 can',
      'time': '10:00 AM'
    },
    {
      'title': 'Training Treats - 85 cal - 5 treats',
      'time': '4:20 PM'
    },
  ];

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
      setState(() {
        _recentMeals.insert(0, {
          'title': '$_selectedFood - ${_quantity.toInt()}g',
          'time': _time.format(context),
        });
      });
    }
  }

  void _navigateToAnalytics() {
    // Placeholder for analytics navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Analytics...')),
    );
  }

  void _scanBarcode() {
    // Placeholder for barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Launching barcode scanner...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _time.format(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pet Nutrition'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: 0.6,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            color: Colors.teal,
                          ),
                        ),
                        const Text('60%', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(today, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('1,250 cal consumed', style: TextStyle(fontSize: 14)),
                          const Text('Goal: 2,000 cal', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _navigateToAnalytics,
                            icon: const Icon(Icons.bar_chart, color: Colors.teal),
                            label: const Text('Analytics', style: TextStyle(color: Colors.teal)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.teal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Log Meal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Select saved food and enter quantity + time.'),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedFood,
                        items: const [
                          DropdownMenuItem(
                            value: 'Dry Kibble - Royal Canin - Dry',
                            child: Text('Dry Kibble - Royal Canin - Dry'),
                          ),
                          DropdownMenuItem(
                            value: 'Wet Food - Hill\'s Science - Wet',
                            child: Text('Wet Food - Hill\'s Science - Wet'),
                          ),
                          DropdownMenuItem(
                            value: 'Treats - Blue Buffalo - Snack',
                            child: Text('Treats - Blue Buffalo - Snack'),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedFood = val!),
                        decoration: const InputDecoration(
                          labelText: 'Food (Name - Brand - Type)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.teal),
                          label: const Text('Scan New Food', style: TextStyle(color: Colors.teal)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.teal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
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
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text('Log Meal', style: TextStyle(fontSize: 16)),
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._recentMeals.map((meal) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.fastfood, color: Colors.teal),
                    title: Text(meal['title']!),
                    subtitle: Text(meal['time']!, style: const TextStyle(color: Colors.grey)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
