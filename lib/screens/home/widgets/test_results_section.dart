import 'package:flutter/material.dart';
import 'package:diabetes_test/test_results_provider.dart';
import 'package:diabetes_test/screens/detection/diabetes_detection_screen.dart';
import 'package:provider/provider.dart';

// Component to display test results
class TestResultsSection extends StatelessWidget {
  const TestResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestResultsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoadingCard();
        }
        
        if (provider.error != null) {
          return _buildErrorCard(context, provider);
        }
        
        if (provider.results.isEmpty) {
          return _buildEmptyCard(context);
        }
        
        // Show most recent test
        final latestResult = provider.results.first;
        return _buildResultCard(context, latestResult);
      },
    );
  }
  
  Widget _buildResultCard(BuildContext context, TestResult result) {
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
            Row(
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
                  '${result.timestamp.day}/${result.timestamp.month}/${result.timestamp.year}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
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
                  child: _buildGaugeIndicator(context, result.sugarLevel),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGaugeIndicator(BuildContext context, double sugarLevel) {
    // Determine color based on sugar level
    Color gaugeColor = Colors.green;
    if (sugarLevel > 140) {
      gaugeColor = Colors.orange;
    }
    if (sugarLevel > 200) {
      gaugeColor = Colors.red;
    }
    
    // Calculate percentage for gauge (assuming range 70-250)
    final minValue = 70.0;
    final maxValue = 250.0;
    final percentage = ((sugarLevel - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 8,
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
              ),
            ),
          ),
          Center(
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your test results...'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorCard(BuildContext context, TestResultsProvider provider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade100),
      ),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              provider.error ?? 'Failed to load test results',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.setState(() {}),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_chart,
                size: 48,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Test Results Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take your first eye test to start monitoring your health',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiabetesDetectionScreen(),
                ),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Eye Test'),
            ),
          ],
        ),
      ),
    );
  }
}