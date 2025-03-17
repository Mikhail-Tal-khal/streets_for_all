import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:flutter/material.dart';
import '../models/health_tip.dart';

class HealthTipsProvider with ChangeNotifier {
  List<HealthTip> _tips = [];
  bool _isLoading = false;
  String? _error;

  List<HealthTip> get tips => _tips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Sample health tips for demo
  static final List<HealthTip> sampleTips = [
    HealthTip(
      id: '1',
      title: 'Stay Hydrated',
      description: 'Drink at least 8 glasses of water daily to maintain healthy blood sugar levels.',
      fullContent: '''
Staying hydrated is crucial for maintaining healthy blood sugar levels and overall health. Here's why:

1. Helps regulate blood sugar
2. Supports kidney function
3. Reduces diabetes risk
4. Aids in maintaining energy levels

Tips for staying hydrated:
- Keep a water bottle handy
- Set reminders to drink water
- Monitor your urine color
- Add natural flavors like lemon or cucumber
      ''',
      icon: Icons.water_drop,
      category: 'Lifestyle',
      tags: ['hydration', 'diabetes', 'health'],
      publishedDate: DateTime.now(),
    ),
    HealthTip(
      id: '2',
      title: 'Regular Exercise',
      description: 'Maintain an active lifestyle with at least 30 minutes of daily exercise.',
      fullContent: '''
Regular exercise is essential for managing diabetes and maintaining overall health:

Benefits of regular exercise:
1. Improves insulin sensitivity
2. Helps control blood sugar
3. Reduces cardiovascular risk
4. Aids in weight management

Recommended activities:
- Walking
- Swimming
- Cycling
- Yoga
- Light resistance training
      ''',
      icon: Icons.directions_run,
      category: 'Exercise',
      tags: ['fitness', 'diabetes', 'health'],
      publishedDate: DateTime.now(),
    ),
    HealthTip(
      id: '3',
      title: 'Balanced Diet',
      description: 'Follow a balanced diet rich in whole grains, lean proteins, and vegetables.',
      fullContent: '''
A balanced diet is crucial for managing diabetes and maintaining good health:

Key components of a balanced diet:
1. Whole grains
2. Lean proteins
3. Vegetables and fruits
4. Healthy fats

Tips for healthy eating:
- Control portion sizes
- Eat at regular intervals
- Monitor carbohydrate intake
- Choose low glycemic index foods
      ''',
      icon: Icons.restaurant,
      category: 'Nutrition',
      tags: ['diet', 'diabetes', 'health'],
      publishedDate: DateTime.now(),
    ),
  ];

  Future<void> fetchHealthTips() async {
    try {
      setState(() => _isLoading = true);
      
      _tips = sampleTips;
      _error = null;
    } catch (e) {
      _error = 'Failed to load health tips';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  updateAuthState(bool isAuthenticated) {}
   void updateAuth(UserAuthProvider auth) {
    // Your auth-dependent initialization
    notifyListeners();
  }
}


