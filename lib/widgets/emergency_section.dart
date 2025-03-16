// lib/widgets/emergency_section.dart
import 'package:flutter/material.dart';

class EmergencySection extends StatelessWidget {
  final VoidCallback onSendAlertPressed;
  final VoidCallback onCallEmergencyPressed;

  const EmergencySection({
    super.key,
    required this.onSendAlertPressed,
    required this.onCallEmergencyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Emergency Assistance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'If you\'re experiencing a medical emergency, please send an alert to get immediate help from available doctors.',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSendAlertPressed,
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Send Emergency Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'OR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCallEmergencyPressed,
              icon: const Icon(Icons.phone),
              label: const Text('Call Emergency Services (911)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}