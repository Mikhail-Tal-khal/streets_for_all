// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes_test/models/history_item.dart';
import 'package:intl/intl.dart';

import '../../test_results_provider.dart';
import 'widgets/history_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement History'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<TestResultsProvider>(
        builder: (context, provider, _) {
          if (provider.results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, 
                      size: 64, 
                      color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Records Found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your blood sugar measurements will appear here',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final result = provider.results[index];
              return HistoryCard(result: result);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(item.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('hh:mm a').format(item.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetric(
                  icon: Icons.monitor_heart_outlined,
                  value: '${item.bloodSugar.toStringAsFixed(0)}%',
                  label: 'Blood Sugar',
                  color: _getBloodSugarColor(item.bloodSugar),
                ),
                const SizedBox(width: 24),
                _buildMetric(
                  icon: Icons.favorite_outline,
                  value: '${item.heartRate}BPM',
                  label: 'Heart Rate',
                  color: _getHeartRateColor(item.heartRate),
                ),
                const SizedBox(width: 24),
                _buildStatusIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(item.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.status,
        style: TextStyle(
          color: _getStatusColor(item.status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBloodSugarColor(double level) {
    if (level > 180) return Colors.red;
    if (level > 140) return Colors.orange;
    return Colors.green;
  }

  Color _getHeartRateColor(int bpm) {
    if (bpm > 100) return Colors.red;
    if (bpm > 80) return Colors.orange;
    return Colors.green;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'elevated':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}