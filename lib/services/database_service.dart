
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
    required double sugarLevel,
    required DateTime timestamp,
  }) async {
    final testData = {
      'userId': userId,
      'sugarLevel': sugarLevel,
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': await _getDeviceInfo(),
    };
    
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Save locally if offline
      await _saveTestResultLocally(testData);
      return;
    }
    
    try {
      // Try to save to Firestore
      await _db.collection('test_results').add(testData);
      
      // Also sync any pending offline data
      await syncOfflineData();
    } catch (e) {
      // Failed to save online, store locally
      await _saveTestResultLocally(testData);
      rethrow;
    }
  }
  
  Future<void> _saveTestResultLocally(Map<String, dynamic> testData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing offline data
      final List<String> offlineData = prefs.getStringList(_offlineTestResultsKey) ?? [];
      
      // Add new test result
      offlineData.add(jsonEncode(testData));
      
      // Save updated list
      await prefs.setStringList(_offlineTestResultsKey, offlineData);
    } catch (e) {
      print('Error saving test result locally: $e');
    }
  }
  
  Future<void> syncOfflineData() async {
    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return; // Still offline, can't sync
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> offlineData = prefs.getStringList(_offlineTestResultsKey) ?? [];
      
      if (offlineData.isEmpty) return; // No data to sync
      
      // Batch write to Firestore
      final batch = _db.batch();
      
      for (final dataString in offlineData) {
        final data = jsonDecode(dataString) as Map<String, dynamic>;
        final docRef = _db.collection('test_results').doc();
        batch.set(docRef, data);
      }
      
      // Commit the batch
      await batch.commit();
      
      // Clear synced data
      await prefs.setStringList(_offlineTestResultsKey, []);
      
    } catch (e) {
      print('Error syncing offline data: $e');
      // Keep the offline data for next sync attempt
    }
  }

  Stream<QuerySnapshot> getTestResults(String userId) {
    return _db
        .collection('test_results')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  Future<List<Map<String, dynamic>>> getTestResultsOffline(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> offlineData = prefs.getStringList(_offlineTestResultsKey) ?? [];
      
      // Parse and filter by userId
      final userResults = offlineData
          .map((dataString) => jsonDecode(dataString) as Map<String, dynamic>)
          .where((data) => data['userId'] == userId)
          .toList();
          
      // Sort by timestamp (descending)
      userResults.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['timestamp']);
        final DateTime dateB = DateTime.parse(b['timestamp']);
        return dateB.compareTo(dateA);
      });
      
      return userResults;
    } catch (e) {
      print('Error getting offline test results: $e');
      return [];
    }
  }
  
  Future<Map<String, String>> _getDeviceInfo() async {
    // In a real app, you'd use device_info_plus package
    // This is a simplified version
    return {
      'platform': 'mobile',
      'appVersion': '1.0.0',
    };
  }
  
  // Helper to check if we're online
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}