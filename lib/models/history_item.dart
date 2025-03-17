import 'package:intl/intl.dart';

class HistoryItem {
  final DateTime timestamp;
  final double bloodSugar;
  final String status;
  final int heartRate;

  HistoryItem({
    required this.timestamp,
    required this.bloodSugar,
    required this.status,
    required this.heartRate,
  });

  String get formattedDate => DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
}