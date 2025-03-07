import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestHistoryCard extends StatelessWidget {
  final double sugarLevel;
  final DateTime timestamp;

  const TestHistoryCard({
    super.key,
    required this.sugarLevel,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNormal = sugarLevel < 140;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sugar Level: ${sugarLevel.toStringAsFixed(1)} mg/dL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  isNormal ? Icons.check_circle : Icons.warning,
                  color: isNormal ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Test Date: ${DateFormat('MMM dd, yyyy HH:mm').format(timestamp)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isNormal ? 'Normal Range' : 'Above Normal Range',
              style: TextStyle(
                color: isNormal ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}