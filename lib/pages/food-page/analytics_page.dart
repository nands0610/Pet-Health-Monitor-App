import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 Nutrition Insights",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: "Weekly Calorie Intake",
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 2500,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                          interval: 1,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: [1800, 2000, 1600, 2100, 1750, 1900, 2200][index].toDouble(),
                            color: Colors.teal,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Water Intake Progress",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today: 650ml / 1000ml"),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Most Frequent Foods",
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.fastfood, color: Colors.teal),
                    title: Text("Dry Kibble - Royal Canin"),
                    trailing: Text("5x/week"),
                  ),
                  ListTile(
                    leading: Icon(Icons.lunch_dining, color: Colors.teal),
                    title: Text("Wet Food - Hill's Science"),
                    trailing: Text("3x/week"),
                  ),
                  ListTile(
                    leading: Icon(Icons.emoji_food_beverage, color: Colors.teal),
                    title: Text("Training Treats"),
                    trailing: Text("2x/week"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
