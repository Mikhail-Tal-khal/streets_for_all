// lib/providers/test_results_provider.dart
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:diabetes_test/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TestResult {
  final String id;
  final double sugarLevel;
  final DateTime timestamp;
  final bool isNormal;

  TestResult({
    required this.id,
    required this.sugarLevel,
    required this.timestamp,
    required this.isNormal,
  });

  factory TestResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestResult(
      id: doc.id,
      sugarLevel: data['sugarLevel'] ?? 0.0,
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      isNormal: (data['sugarLevel'] ?? 0.0) < 140.0,
    );
  }

  factory TestResult.fromOfflineData(Map<String, dynamic> data) {
    return TestResult(
      id: data['offlineId'] ?? DateTime.now().toIso8601String(),
      sugarLevel: data['sugarLevel'] ?? 0.0,
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      isNormal: (data['sugarLevel'] ?? 0.0) < 140.0,
    );
  }
}

class TestResultsProvider with ChangeNotifier {
  List<TestResult> _results = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  DatabaseService? _dbService;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<TestResult> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(String? userId, DatabaseService? dbService) {
    // Only update if something changed
    if (_userId == userId && _dbService == dbService) return;

    _userId = userId;
    _dbService = dbService;

    // Cancel previous subscription if exists
    _subscription?.cancel();

    if (userId != null && dbService != null) {
      _loadTestResults();
    } else {
      _results = [];
      notifyListeners();
    }
  }

  Future<void> _loadTestResults() async {
    if (_userId == null || _dbService == null) return;

    setState(() => _isLoading = true);
    
    try {
      // Start listening to Firestore results
      _subscription = _dbService!.getTestResults(_userId!).listen(
        (snapshot) {
          final onlineResults = snapshot.docs
              .map((doc) => TestResult.fromFirestore(doc))
              .toList();
          
          _results = onlineResults;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = "Failed to load test results: $e";
          notifyListeners();
          
          // On Firestore error, try to load offline data
          _loadOfflineResults();
        },
      );
      
      // Also immediately try to load offline data in case we're offline
      await _loadOfflineResults();
    } catch (e) {
      _error = "Failed to load test results";
      notifyListeners();
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadOfflineResults() async {
    if (_userId == null || _dbService == null) return;
    
    try {
      final offlineResults = await _dbService!.getTestResultsOffline(_userId!);
      
      // If we have no online results yet, use offline ones
      if (_results.isEmpty && offlineResults.isNotEmpty) {
        _results = offlineResults
            .map((data) => TestResult.fromOfflineData(data))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading offline results: $e');
    }
  }

  Future<void> saveTestResult(double sugarLevel) async {
    if (_userId == null || _dbService == null) {
      _error = "You must be logged in to save results";
      notifyListeners();
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _dbService!.saveTestResult(
        userId: _userId!,
        sugarLevel: sugarLevel,
        timestamp: DateTime.now(),
      );
      
      _error = null;
    } catch (e) {
      _error = "Failed to save test result: $e";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}