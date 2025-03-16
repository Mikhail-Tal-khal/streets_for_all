import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakProvider with ChangeNotifier {
  int _currentStreak = 0;
  
  StreakProvider() {
    _loadStreak();
  }

  int get currentStreak => _currentStreak;

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    notifyListeners();
  }

  Future<void> incrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak++;
    await prefs.setInt('current_streak', _currentStreak);
    notifyListeners();
  }

  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = 0;
    await prefs.setInt('current_streak', _currentStreak);
    notifyListeners();
  }
}