// ===========================
// FILE: home_page.dart
// ===========================
import 'package:flutter/material.dart';
import 'metric_card.dart';
import 'vet_page.dart';
import 'food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    VetPage(),
    _HomeContent(),
    FoodPage(),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MetricCard(title: 'Temperature (°C)', sensorKey: 'temperature'),
          const SizedBox(height: 12),
          const MetricCard(title: 'Heart Rate (BPM)', sensorKey: 'heartRate'),
          const SizedBox(height: 12),
          const MetricCard(title: 'Activity Level', sensorKey: 'activity'),
          const SizedBox(height: 24),
          Text(
            'Pet Location',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Map Placeholder'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  }


class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          const MetricCard(title: 'Temperature (°C)', sensorKey: 'temperature'),
          SizedBox(height: 16),
          const MetricCard(title: 'Heart Rate (BPM)', sensorKey: 'heartRate'),
          SizedBox(height: 16),
          const MetricCard(title: 'Activity Level', sensorKey: 'activity'),
          _MapSection(),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Map Placeholder (GPS)',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
