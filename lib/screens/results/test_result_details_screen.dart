// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:diabetes_test/models/health_tip.dart';
import 'package:diabetes_test/screens/health_tip_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TestResultDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final DateTime timestamp;

  const TestResultDetailsScreen({
    super.key,
    required this.resultData,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final sugarLevel = resultData['sugarEstimate'] ?? 0.0;
    final severity = resultData['severity'] ?? 'Unknown';
    final isNormal = resultData['isNormal'] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context),
            tooltip: 'Share Results',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHeader(context, isNormal),
            _buildBloodGlucoseSection(context, sugarLevel, severity),
            _buildRiskIndicator(context, sugarLevel, severity),
            _buildRecommendationsSection(context, sugarLevel, severity),
            _buildNextStepsSection(context, sugarLevel, severity),
            _buildRelatedHealthTips(context, sugarLevel, severity),
            _buildDisclaimerSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.done),
        label: const Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildResultHeader(BuildContext context, bool isNormal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isNormal ? Colors.green.shade700 : Colors.orange.shade700,
            isNormal ? Colors.green.shade500 : Colors.orange.shade500,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Icon(
                  isNormal ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNormal ? 'Normal Reading' : 'Elevated Reading',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy - hh:mm a').format(timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGlucoseSection(
    BuildContext context,
    double sugarLevel,
    String severity,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blood Glucose',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Estimated Level',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${sugarLevel.toStringAsFixed(1)} mg/dL',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Retinopathy Grade',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        severity,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getSeverityColor(severity),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(
    BuildContext context,
    double sugarLevel,
    String severity,
  ) {
    // Calculate risk level based on sugar level
    final normalRange = sugarLevel < 140;
    final preDiabetic = sugarLevel >= 140 && sugarLevel < 200;
    final diabetic = sugarLevel >= 200;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Risk Assessment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: _getRiskFactor(sugarLevel),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getRiskGradient(sugarLevel),
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Normal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          normalRange ? FontWeight.bold : FontWeight.normal,
                      color: normalRange ? Colors.green : Colors.grey,
                    ),
                  ),
                  Text(
                    'Pre-Diabetic',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          preDiabetic ? FontWeight.bold : FontWeight.normal,
                      color: preDiabetic ? Colors.orange : Colors.grey,
                    ),
                  ),
                  Text(
                    'Diabetic',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          diabetic ? FontWeight.bold : FontWeight.normal,
                      color: diabetic ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMessageBackgroundColor(sugarLevel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMessageIcon(sugarLevel),
                      color: _getMessageIconColor(sugarLevel),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getRiskMessage(sugarLevel, severity),
                        style: TextStyle(
                          color: _getMessageTextColor(sugarLevel),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    double sugarLevel,
    String severity,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._getRecommendationItems(sugarLevel, severity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepsSection(
    BuildContext context,
    double sugarLevel,
    String severity,
  ) {
    final isHighRisk =
        sugarLevel >= 200 ||
        severity == 'Moderate NPDR' ||
        severity == 'Severe NPDR' ||
        severity == 'PDR';

    final isMediumRisk =
        sugarLevel >= 140 && sugarLevel < 200 || severity == 'Mild NPDR';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next Steps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isHighRisk
                            ? Colors.red.withOpacity(0.1)
                            : isMediumRisk
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    child: Icon(
                      isHighRisk
                          ? Icons.medical_services
                          : isMediumRisk
                          ? Icons.calendar_today
                          : Icons.check,
                      color:
                          isHighRisk
                              ? Colors.red
                              : isMediumRisk
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isHighRisk
                          ? 'Seek medical attention within the next 7 days'
                          : isMediumRisk
                          ? 'Schedule a follow-up with your healthcare provider'
                          : 'Continue regular monitoring',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today),
                label: const Text('Schedule Appointment'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedHealthTips(
    BuildContext context,
    double sugarLevel,
    String severity,
  ) {
    // Get relevant health tips based on sugar level and severity
    final List<HealthTip> relevantTips = _getRelevantHealthTips(
      sugarLevel,
      severity,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Health Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...relevantTips.map((tip) => _buildHealthTipCard(context, tip)),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard(BuildContext context, HealthTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthTipDetailScreen(tip: tip),
              ),
            ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  tip.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: const [
          Text(
            'IMPORTANT DISCLAIMER',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'This application provides an estimated blood glucose level based on retinal image analysis. '
            'It is intended for screening purposes only and should not replace proper medical testing. '
            'Please consult with a healthcare professional for accurate diagnosis and treatment.',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context) {
    final sugarLevel = resultData['sugarEstimate']?.toStringAsFixed(1) ?? '0.0';
    final severity = resultData['severity'] ?? 'Unknown';
    final formattedDate = DateFormat('MMMM dd, yyyy').format(timestamp);

    final textToShare =
        'SugarPlus Test Results\n'
        'Date: $formattedDate\n'
        'Estimated Blood Glucose: $sugarLevel mg/dL\n'
        'Retinopathy Grade: $severity\n\n'
        'This is a screening result only. Please consult with a healthcare professional for accurate diagnosis.';

    Share.share(textToShare, subject: 'SugarPlus Test Results');
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'No DR':
        return Colors.green;
      case 'Mild NPDR':
        return Colors.lightGreen;
      case 'Moderate NPDR':
        return Colors.orange;
      case 'Severe NPDR':
        return Colors.deepOrange;
      case 'PDR':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  double _getRiskFactor(double sugarLevel) {
    if (sugarLevel < 70) {
      // Hypoglycemia
      return 0.1;
    } else if (sugarLevel < 100) {
      // Normal low
      return 0.2;
    } else if (sugarLevel < 140) {
      // Normal high
      return 0.33;
    } else if (sugarLevel < 200) {
      // Pre-diabetic
      return 0.67;
    } else {
      // Diabetic
      return 1.0;
    }
  }

  List<Color> _getRiskGradient(double sugarLevel) {
    if (sugarLevel < 140) {
      // Normal
      return [Colors.green.shade300, Colors.green.shade600];
    } else if (sugarLevel < 200) {
      // Pre-diabetic
      return [Colors.orange.shade300, Colors.orange.shade700];
    } else {
      // Diabetic
      return [Colors.red.shade300, Colors.red.shade700];
    }
  }

  Color _getMessageBackgroundColor(double sugarLevel) {
    if (sugarLevel < 140) {
      return Colors.green.shade50;
    } else if (sugarLevel < 200) {
      return Colors.orange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  Color _getMessageIconColor(double sugarLevel) {
    if (sugarLevel < 140) {
      return Colors.green;
    } else if (sugarLevel < 200) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getMessageTextColor(double sugarLevel) {
    if (sugarLevel < 140) {
      return Colors.green.shade900;
    } else if (sugarLevel < 200) {
      return Colors.orange.shade900;
    } else {
      return Colors.red.shade900;
    }
  }

  IconData _getMessageIcon(double sugarLevel) {
    if (sugarLevel < 140) {
      return Icons.check_circle;
    } else if (sugarLevel < 200) {
      return Icons.info;
    } else {
      return Icons.warning;
    }
  }

  String _getRiskMessage(double sugarLevel, String severity) {
    if (sugarLevel < 70) {
      return 'Your estimated glucose level is below normal range. This may indicate hypoglycemia.';
    } else if (sugarLevel < 140) {
      return 'Your estimated glucose level is within normal range. Continue maintaining healthy habits.';
    } else if (sugarLevel < 200) {
      return 'Your estimated glucose level is elevated. This may indicate pre-diabetes. Consider lifestyle modifications.';
    } else {
      return 'Your estimated glucose level is high. This may indicate diabetes. Please consult with a healthcare provider.';
    }
  }

  List<Widget> _getRecommendationItems(double sugarLevel, String severity) {
    final List<Widget> recommendations = [];

    // Add recommendations based on sugar level
    if (sugarLevel < 70) {
      // Hypoglycemia recommendations
      recommendations.add(
        _buildRecommendationItem(
          'Consume fast-acting carbohydrates',
          'Consider glucose tablets, fruit juice, or honey to raise blood sugar quickly',
          Icons.restaurant,
        ),
      );
    } else if (sugarLevel < 140) {
      // Normal recommendations
      recommendations.add(
        _buildRecommendationItem(
          'Maintain healthy lifestyle',
          'Continue with balanced diet, regular exercise, and adequate hydration',
          Icons.favorite,
        ),
      );
    } else if (sugarLevel < 200) {
      // Pre-diabetic recommendations
      recommendations.add(
        _buildRecommendationItem(
          'Adjust diet and exercise',
          'Reduce sugar intake, increase physical activity, and monitor carbohydrate consumption',
          Icons.directions_run,
        ),
      );
      recommendations.add(
        _buildRecommendationItem(
          'Schedule a follow-up',
          'Consider getting a traditional blood glucose test for confirmation',
          Icons.calendar_today,
        ),
      );
    } else {
      // Diabetic recommendations
      recommendations.add(
        _buildRecommendationItem(
          'Consult a healthcare provider',
          'Seek professional medical advice for proper diagnosis and treatment plan',
          Icons.medical_services,
        ),
      );
      recommendations.add(
        _buildRecommendationItem(
          'Monitor blood glucose regularly',
          'Consider getting a glucometer for daily monitoring',
          Icons.monitor_heart,
        ),
      );
      recommendations.add(
        _buildRecommendationItem(
          'Diet and lifestyle changes',
          'Follow a diabetic-appropriate diet and increase physical activity as advised',
          Icons.restaurant_menu,
        ),
      );
    }

    // Add recommendations based on retinopathy severity
    if (severity == 'Moderate NPDR' ||
        severity == 'Severe NPDR' ||
        severity == 'PDR') {
      recommendations.add(
        _buildRecommendationItem(
          'Ophthalmological examination',
          'Schedule an appointment with an eye specialist as soon as possible',
          Icons.visibility,
        ),
      );
    }

    return recommendations;
  }

  Widget _buildRecommendationItem(
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<HealthTip> _getRelevantHealthTips(double sugarLevel, String severity) {
    // In a real app, you would fetch these from a provider or database
    // based on the sugar level and severity

    // For demonstration purposes, returning sample tips
    return [
      HealthTip(
        id: '1',
        title: 'Stay Hydrated',
        description:
            'Drink at least 8 glasses of water daily to maintain healthy blood sugar levels.',
        fullContent:
            'Staying hydrated helps your kidneys flush out excess sugar through urine. Aim for at least 8 glasses of water daily, and more if you exercise or during hot weather.',
        icon: Icons.water_drop,
        category: 'Lifestyle',
        tags: ['hydration', 'diabetes', 'health'],
        publishedDate: DateTime.now(),
      ),
      HealthTip(
        id: '2',
        title: 'Regular Exercise',
        description:
            'Maintain an active lifestyle with at least 30 minutes of daily exercise.',
        fullContent:
            'Regular physical activity helps improve insulin sensitivity and blood circulation. Try for at least 30 minutes of moderate exercise most days of the week.',
        icon: Icons.directions_run,
        category: 'Exercise',
        tags: ['fitness', 'diabetes', 'health'],
        publishedDate: DateTime.now(),
      ),
      HealthTip(
        id: '3',
        title: 'Eye Care Tips',
        description: 'Protect your eyes with regular checkups and proper care.',
        fullContent:
            'Regular eye exams are crucial for detecting early signs of diabetic retinopathy. Protect your eyes from UV light and follow a diet rich in antioxidants.',
        icon: Icons.visibility,
        category: 'Eye Health',
        tags: ['eyes', 'vision', 'retinopathy'],
        publishedDate: DateTime.now(),
      ),
    ];
  }
}
