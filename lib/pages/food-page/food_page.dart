import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'barcode_scanner_page.dart';
import 'dart:ui';
import 'analytics_page.dart';


class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _selectedFood = 'Dry Kibble - Royal Canin - Dry';
  double _quantity = 100;
  double _waterIntake = 650;
  double _waterGoal = 1000;
  TimeOfDay _time = TimeOfDay.now();
  bool _showGoalAnimation = false;
  bool _showDogAnimation = false;

  late AnimationController _dogController;

final List<Map<String, String>> _recentMeals = [
  {
    'title': 'Premium Dry Food - 420 cal - 1.5 cups',
    'time': '1:30 PM',
    'note': 'Finished all of it'
  },
  {
    'title': 'Wet Food - 380 cal - 1 can',
    'time': '10:00 AM',
    'note': ''
  },
  {
    'title': 'Training Treats - 85 cal - 5 treats',
    'time': '4:20 PM',
    'note': 'Was distracted and left halfway'
  },
];

  List<String> _foodOptions = [
    'Dry Kibble - Royal Canin - Dry',
    'Wet Food - Hill\'s Science - Wet',
    'Treats - Blue Buffalo - Snack',
  ];

  @override
  void initState() {
    super.initState();
    _dogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _dogController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() => _time = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
_recentMeals.insert(0, {
  'title': '$_selectedFood - ${_quantity.toInt()}g',
  'time': _time.format(context),
  'note': ''
});
        _showDogAnimation = true;
        _dogController.forward(from: 0);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showDogAnimation = false);
        });
      });
    }
  }

  void _navigateToAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsPage()),
    );
  }

  void _editNoteForMeal(Map<String, String> meal) {
  final controller = TextEditingController(text: meal['note']);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add/Edit Note'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'E.g., didn’t finish, ate half'),
        maxLines: null,
        minLines: 1
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            setState(() {
              meal['note'] = controller.text.trim();
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}


  Future<void> _scanAndAddFood() async {
    final scannedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (scannedName != null && scannedName is String) {
      final controller = TextEditingController(text: scannedName);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Food Name"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty && !_foodOptions.contains(name)) {
                  setState(() {
                    _foodOptions.add(name);
                    _selectedFood = name;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      );
    }
  }

  void _scanBarcode() => _scanAndAddFood();

  void _addWater(double amount) {
    setState(() {
      _waterIntake += amount;
      if (_waterIntake >= _waterGoal && !_showGoalAnimation) {
        _showGoalAnimation = true;
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showGoalAnimation = false);
        });
      }
    });
  }

  void _showCustomWaterDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Water Intake'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Enter amount in ml'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                _addWater(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _time.format(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final waterProgress = (_waterIntake / _waterGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title:
            const Text('Pet Nutrition', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top summary card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                            const Text('60%',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(today,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              const Text('1,250 cal consumed',
                                  style: TextStyle(fontSize: 14)),
                              const Text('Goal: 2,000 cal',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              const SizedBox(height: 8),
LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth > 360;
    final buttonStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.teal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    final analyticsButton = OutlinedButton.icon(
      onPressed: _navigateToAnalytics,
      icon: const Icon(Icons.bar_chart, color: Colors.teal),
      label: const Text('Analytics', style: TextStyle(color: Colors.teal)),
      style: buttonStyle,
    );

    final scanButton = OutlinedButton.icon(
      onPressed: _scanBarcode,
      icon: const Icon(Icons.qr_code_scanner, color: Colors.teal),
      label: const Text('Scan Food', style: TextStyle(color: Colors.teal)),
      style: buttonStyle,
    );

    return isWide
        ? Row(
            children: [
              Expanded(child: analyticsButton),
              const SizedBox(width: 8),
              Expanded(child: scanButton),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              analyticsButton,
              const SizedBox(height: 8),
              scanButton,
            ],
          );
  },
),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Meal form
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Log Meal',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedFood,
                            items: _foodOptions.map((food) {
                              return DropdownMenuItem(
                                  value: food, child: Text(food));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedFood = val!),
                            decoration: const InputDecoration(
                              labelText: 'Food (Name - Brand - Type)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _quantity.toString(),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Quantity (grams)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              final num? qty = num.tryParse(val ?? '');
                              if (qty == null || qty <= 0)
                                return 'Enter a valid quantity';
                              return null;
                            },
                            onChanged: (val) {
                              final num? qty = num.tryParse(val);
                              if (qty != null) _quantity = qty.toDouble();
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
                                iconColor: Color.fromARGB(255, 255, 255, 255),
                                backgroundColor: Colors.teal,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              label: const Text('Log Meal',
                                  style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 255, 255))),
                              onPressed: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Water Tracker
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.water_drop, color: Colors.blueAccent),
                            SizedBox(width: 6),
                            Text('Water Intake',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: waterProgress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 12),
                        Text(
                            '${_waterIntake.toInt()}ml / ${_waterGoal.toInt()}ml',
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: [
                            OutlinedButton(
                                onPressed: () => _addWater(50),
                                child: const Text('+50ml')),
                            OutlinedButton(
                                onPressed: () => _addWater(100),
                                child: const Text('+100ml')),
                            OutlinedButton(
                                onPressed: () => _addWater(200),
                                child: const Text('+200ml')),
                            OutlinedButton(
                                onPressed: _showCustomWaterDialog,
                                child: const Text('Custom')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Recent meals
                const Text('Recent Meals',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
..._recentMeals.map((meal) => Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)),
  child: ListTile(
    title: Text(meal['title']!),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(meal['time']!, style: const TextStyle(color: Color(0xFF555555))),
        if (meal['note'] != null && meal['note']!.isNotEmpty)
          Text('Note: ${meal['note']!}',
              style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    ),
    trailing: IconButton(
      icon: const Icon(Icons.edit, color: Colors.teal),
      onPressed: () => _editNoteForMeal(meal),
    ),
  ),
))

              ],
            ),
          ),
          if (_showGoalAnimation)
            Center(
              child:
                  Lottie.asset('assets/celebration.json', width: 200, repeat: false),
            ),
if (_showDogAnimation)
  AnimatedBuilder(
    animation: _dogController,
    builder: (context, child) {
      final screenWidth = MediaQuery.of(context).size.width;
      const dogWidth = 160.0;
      const overshoot = 200.0; // 👈 how far *beyond* the screen it goes

      final leftOffset = lerpDouble(
        -dogWidth,                     // start: offscreen to the left
        screenWidth + dogWidth + overshoot, // end: way offscreen to the right
        _dogController.value,
      );

      return Positioned(
        bottom: 10, // Adjust for vertical placement if needed
        left: leftOffset,
        child: SizedBox(
          width: dogWidth,
          child: Lottie.asset(
            'assets/dog-walk.json',
            repeat: false,
          ),
        ),
      );
    },
  ),



        ],
      ),
    );
  }
}

