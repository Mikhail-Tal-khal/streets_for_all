import 'package:flutter/material.dart';

class GaugeIndicator extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final double size;

  const GaugeIndicator({
    super.key,
    required this.value,
    this.minValue = 70.0,
    this.maxValue = 250.0,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on value
    Color gaugeColor = Colors.green;
    if (value > 140) {
      gaugeColor = Colors.orange;
    }
    if (value > 200) {
      gaugeColor = Colors.red;
    }
    
    // Calculate percentage
    final percentage = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          // Background circle
          Center(
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: size * 0.1,
                ),
              ),
            ),
          ),
          // Progress indicator
          Center(
            child: SizedBox(
              height: size,
              width: size,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: size * 0.1,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
              ),
            ),
          ),
          // Percentage text
          Center(
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.18,
                fontWeight: FontWeight.bold,
                color: gaugeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}