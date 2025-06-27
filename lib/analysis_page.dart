import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Latest Insights',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        // Insight cards (reuse MetricCard for visual consistency)
        const MetricCard(
          icon: Icons.thermostat,
          label: 'Avg Temp (24h)',
          value: '25.2 °C',
        ),
        const SizedBox(height: 16),
        const MetricCard(
          icon: Icons.favorite,
          label: 'Avg HR (24h)',
          value: '78 bpm',
        ),
        const SizedBox(height: 24),

        // Chart placeholder
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade100, width: 2),
          ),
          child: Center(
            child: Text(
              '📈 Trend chart coming soon …',
              style: TextStyle(color: Colors.teal.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
