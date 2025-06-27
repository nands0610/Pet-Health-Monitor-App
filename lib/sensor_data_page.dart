import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';

class SensorDataPage extends StatelessWidget {
  const SensorDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        //  ⬇  width / height  (0.75 ⇒ tile height ≈ 1.33 × its width)
        childAspectRatio: 0.75,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MetricCard(icon: Icons.thermostat, label: 'Temperature', value: '25 °C'),
          MetricCard(icon: Icons.water_drop, label: 'Humidity', value: '55 %'),
          MetricCard(
            icon: Icons.favorite,
            label: 'Heart Rate',
            value: '82 bpm',
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          MetricCard(
            icon: Icons.directions_walk,
            label: 'Activity',
            value: 'Calm',
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }
}
