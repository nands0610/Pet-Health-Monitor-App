import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String sensorKey;

  const MetricCard({
    super.key,
    required this.title,
    required this.sensorKey,
  });

  Stream<List<Map<String, dynamic>>> _sensorDataStream() {
    return FirebaseFirestore.instance
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(24)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _sensorDataStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data!;
            final sorted = data.reversed.toList(); // oldest to newest
            final spots = <FlSpot>[];
            final labels = <int, String>{};

            for (int i = 0; i < sorted.length; i++) {
              final reading = sorted[i];
              final value = (reading[sensorKey] ?? 0).toDouble();
              final timestamp = reading['timestamp'];
              spots.add(FlSpot(i.toDouble(), value));

              // Add labels for even hours only to reduce clutter
              if (timestamp is Timestamp) {
                final time = timestamp.toDate();
                if (i % 3 == 0) {
                  labels[i] = DateFormat.Hm().format(time); // "14:00"
                }
              }
            }

            final latest = sorted.isNotEmpty
                ? (sorted.last[sensorKey] ?? 0).toString()
                : 'N/A';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Current: $latest',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.transparent,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 28,
                            getTitlesWidget: (value, _) {
                              final label = labels[value.toInt()];
                              return Text(
                                label ?? '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItems: (spots) {
                            return spots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.teal,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.teal.withOpacity(0.15),
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
