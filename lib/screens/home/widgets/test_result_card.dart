import 'package:diabetes_test/screens/home/widgets/gauge_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diabetes_test/test_results_provider.dart';

class TestResultCard extends StatelessWidget {
  final TestResult result;
  final VoidCallback? onViewDetails;

  const TestResultCard({
    super.key,
    required this.result,
    this.onViewDetails,
  });

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
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContent(context),
            const SizedBox(height: 16),
            _buildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              result.isNormal ? Icons.check_circle : Icons.warning,
              color: result.isNormal ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              result.isNormal ? 'Normal' : 'Attention Needed',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: result.isNormal ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        Text(
          DateFormat('MMM dd, yyyy').format(result.timestamp),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Glucose Level',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.sugarLevel.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'mg/dL',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                result.isNormal ? 'Within normal range' : 'Above normal range',
                style: TextStyle(
                  fontSize: 12,
                  color: result.isNormal ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: GaugeIndicator(value: result.sugarLevel),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return OutlinedButton(
      onPressed: onViewDetails,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('View Details'),
    );
  }
}