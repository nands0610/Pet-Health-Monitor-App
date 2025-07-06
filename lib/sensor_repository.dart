// sensor_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SensorSnapshot {
  final DateTime timestamp;
  final double temperature;
  final double heartRate;
  final double activity;

  SensorSnapshot({
    required this.timestamp,
    required this.temperature,
    required this.heartRate,
    required this.activity,
  });

  factory SensorSnapshot.fromMap(Map<String, dynamic> data) {
    return SensorSnapshot(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      temperature: (data['temperature'] as num).toDouble(),
      heartRate: (data['heartRate'] as num).toDouble(),
      activity: (data['activity'] as num).toDouble(),
    );
  }
}

class SensorRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<SensorSnapshot>> last24hSnapshots() {
    final from = DateTime.now().subtract(const Duration(hours: 24));
    return _db
        .collection('readings')
        .where('timestamp', isGreaterThan: from)
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => SensorSnapshot.fromMap(doc.data())).toList());
  }
}
