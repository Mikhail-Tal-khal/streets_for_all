// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestResultCard extends StatelessWidget {
  final DateTime date;
  final double sugarLevel;
  final VoidCallback onTap;

  const TestResultCard({
    super.key,
    required this.date,
    required this.sugarLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNormal = sugarLevel < 140;

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isNormal
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isNormal ? Icons.check : Icons.warning,
                      color: isNormal ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd').format(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${sugarLevel.toStringAsFixed(1)} mg/dL',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                isNormal ? 'Normal' : 'High',
                style: TextStyle(
                  color: isNormal ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}