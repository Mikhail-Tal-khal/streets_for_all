// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _offlineTestResultsKey = 'offline_test_results';
  
  DatabaseService() {
    // Enable Firestore offline persistence
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> saveTestResult({
    required String userId,
    required double bloodSugar,
    required int heartRate,
    required DateTime timestamp, required double sugarLevel,
  }) async {
    final testData = {
      'bloodSugar': bloodSugar,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': await _getDeviceInfo(),
    };
    
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Save locally if offline
      await _saveTestResultLocally(userId, testData);
      return;
    }
    
    try {
      // Save to user's subcollection
      await _db.collection('users')
        .doc(userId)
        .collection('tests')
        .add(testData);
      
      // Sync any pending offline data
      await syncOfflineData(userId);
    } catch (e) {
      // Fallback to local storage
      await _saveTestResultLocally(userId, testData);
      rethrow;
    }
  }
  
  Future<void> _saveTestResultLocally(String userId, Map<String, dynamic> testData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extendedData = {
        ...testData,
        'userId': userId,  // Store userId for offline filtering
      };
      
      final List<String> offlineData = 
        prefs.getStringList(_offlineTestResultsKey) ?? [];
      offlineData.add(jsonEncode(extendedData));
      
      await prefs.setStringList(_offlineTestResultsKey, offlineData);
    } catch (e) {
      print('Error saving locally: $e');
    }
  }
  
  Future<void> syncOfflineData(String userId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> offlineData = 
        prefs.getStringList(_offlineTestResultsKey) ?? [];
      
      if (offlineData.isEmpty) return;

      final batch = _db.batch();
      final newOfflineData = <String>[];

      for (final dataString in offlineData) {
        final data = jsonDecode(dataString) as Map<String, dynamic>;
        
        if (data['userId'] == userId) {
          final docRef = _db.collection('users')
            .doc(userId)
            .collection('tests')
            .doc();
          batch.set(docRef, data);
        } else {
          // Keep data for other users
          newOfflineData.add(dataString);
        }
      }
      
      await batch.commit();
      await prefs.setStringList(_offlineTestResultsKey, newOfflineData);
      
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Stream<QuerySnapshot> getTestResults(String userId) {
    return _db.collection('users')
      .doc(userId)
      .collection('tests')
      .orderBy('timestamp', descending: true)
      .snapshots();
  }
  
  Future<List<Map<String, dynamic>>> getTestResultsOffline(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_offlineTestResultsKey)?.map((dataString) {
        final data = jsonDecode(dataString) as Map<String, dynamic>;
        return {
          'bloodSugar': data['bloodSugar']?.toDouble(),
          'heartRate': data['heartRate']?.toInt(),
          'timestamp': data['timestamp'],
        };
      }).where((data) => data['userId'] == userId).toList() ?? [];
    } catch (e) {
      print('Offline read error: $e');
      return [];
    }
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    return {
      'platform': 'mobile',
      'appVersion': '1.0.0',
    };
  }
  
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}