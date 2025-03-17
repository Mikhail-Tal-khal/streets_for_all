import 'package:diabetes_test/models/history_item.dart';
import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:diabetes_test/services/database_service.dart';
import 'package:flutter/material.dart';

class TestResultsProvider with ChangeNotifier {
  final List<HistoryItem> _results = [];
  
  List<HistoryItem> get results => _results;

  void addResult(HistoryItem item) {
    _results.add(item);
    notifyListeners(); // Must call this
  }
  void initialize(UserAuthProvider auth, DatabaseService db) {
    // Your initialization logic
    notifyListeners();
  }
}