import 'package:flutter/material.dart';

class HealthMetricsCard extends StatelessWidget {
  const HealthMetricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Health Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HealthMetric(
                  icon: Icons.opacity_rounded,
                  title: 'Blood Sugar',
                  value: '4.2',
                  unit: 'mmol/L',
                  color: Colors.red.shade400,
                ),
                HealthMetric(
                  icon: Icons.monitor_heart_rounded,
                  title: 'Blood Pressure',
                  value: '120/80',
                  unit: 'mmHg',
                  color: Colors.blue.shade400,
                ),
                HealthMetric(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Activity',
                  value: '2,456',
                  unit: 'steps',
                  color: Colors.green.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HealthMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;

  const HealthMetric({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}