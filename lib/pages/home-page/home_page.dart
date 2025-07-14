// ===========================
// FILE: home_page.dart
// ===========================

import 'package:flutter/material.dart';
import 'package:pet_health/components/home-cards/metric_card.dart';
import '../vet-page/vet_page.dart';
import '../food-page/food_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    VetPage(),
    FoodPage(), // You can change this if needed
    FoodPage(),
  ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pet Health Monitor"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
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
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(12.9716, 77.5946), // Dummy location
                  initialZoom: 13.0,
                    minZoom: 3,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      enableScrollWheel: true, // For desktop/web
                    ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.pet_health_monitor',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(12.9716, 77.5946),
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.pets,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Vet'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
        ],
      ),
    );
  }
}
