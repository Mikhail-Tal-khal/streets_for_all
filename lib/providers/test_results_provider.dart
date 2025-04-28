// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:diabetes_test/models/history_item.dart';
// import 'package:diabetes_test/providers/user_auth_provider.dart';
// import 'package:diabetes_test/services/database_service.dart';
// import 'package:flutter/material.dart';

// class TestResultsProvider with ChangeNotifier {
//   final List<HistoryItem> _results = [];
//   bool _isLoading = false;
//   String? _error;
//   String? _userId;
//   DatabaseService? _dbService;
//   StreamSubscription<QuerySnapshot>? _subscription;

//   List<HistoryItem> get results => _results;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
  
//   get sugarLevel => null;

//   void initialize(UserAuthProvider auth, DatabaseService db) {
//     update(auth.currentUser as String?, db);
//   }

//   void update(String? userId, DatabaseService? dbService) {
//     if (_userId == userId && _dbService == dbService) return;

//     _userId = userId;
//     _dbService = dbService;
//     _subscription?.cancel();

//     if (userId != null && dbService != null) {
//       _loadTestResults();
//     } else {
//       _results.clear();
//       notifyListeners();
//     }
//   }

//   Future<void> _loadTestResults() async {
//     if (_userId == null || _dbService == null) return;

//     _setState(() => _isLoading = true);
    
//     try {
//       _subscription = _dbService!.getTestResults(_userId!).listen(
//         (snapshot) {
//           _results.clear();
//           _results.addAll(snapshot.docs.map(_convertDocumentToHistoryItem));
//           _error = null;
//           notifyListeners();
//         },
//         onError: (e) {
//           _error = "Failed to load test results: $e";
//           notifyListeners();
//           _loadOfflineResults();
//         },
//       );

//       await _loadOfflineResults();
//     } catch (e) {
//       _error = "Failed to load test results";
//       notifyListeners();
//     } finally {
//       _setState(() => _isLoading = false);
//     }
//   }

//   HistoryItem _convertDocumentToHistoryItem(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return HistoryItem(
//       id: doc.id,
//       timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       bloodSugar: data['bloodSugar']?.toDouble() ?? 0.0,
//       status: _getStatus(data['bloodSugar']?.toDouble() ?? 0.0),
//       heartRate: data['heartRate']?.toInt() ?? 0,
//     );
//   }

//   String _getStatus(double bloodSugar) {
//     if (bloodSugar < 140) return 'Normal';
//     if (bloodSugar < 200) return 'Prediabetic';
//     return 'Diabetic';
//   }

//   Future<void> _loadOfflineResults() async {
//     if (_userId == null || _dbService == null) return;
    
//     try {
//       final offlineData = await _dbService!.getTestResultsOffline(_userId!);
//       _results.addAll(offlineData.map(_convertOfflineDataToHistoryItem));
//       notifyListeners();
//     } catch (e) {
//       print('Error loading offline results: $e');
//     }
//   }

//   HistoryItem _convertOfflineDataToHistoryItem(Map<String, dynamic> data) {
//     return HistoryItem(
//       id: data['offlineId'] ?? DateTime.now().toIso8601String(),
//       timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
//       bloodSugar: data['bloodSugar']?.toDouble() ?? 0.0,
//       status: _getStatus(data['bloodSugar']?.toDouble() ?? 0.0),
//       heartRate: data['heartRate']?.toInt() ?? 0,
//     );
//   }

//   Future<void> addResult(HistoryItem item) async {
//     if (_userId == null || _dbService == null) {
//       _error = "You must be logged in to save results";
//       notifyListeners();
//       return;
//     }

//     _setState(() => _isLoading = true);
    
//     try {
//       await _dbService!.saveTestResult(
//         userId: _userId!,
//         bloodSugar: item.bloodSugar,
//         sugarLevel: sugarLevel,
//         heartRate: item.heartRate,
//         timestamp: item.timestamp,
//       );
      
//       _results.add(item);
//       _error = null;
//     } catch (e) {
//       _error = "Failed to save test result: $e";
//     } finally {
//       _setState(() => _isLoading = false);
//     }
//   }

//   void _setState(VoidCallback fn) {
//     fn();
//     notifyListeners();
//   }
  
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }