// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class DiabetesDetectionScreen extends StatefulWidget {
  const DiabetesDetectionScreen({super.key});

  @override
  State<DiabetesDetectionScreen> createState() => _DiabetesDetectionScreenState();
}

class _DiabetesDetectionScreenState extends State<DiabetesDetectionScreen>
    with WidgetsBindingObserver {
  // Configuration constants
  static const _maxReadings = 10;
  static const _normalThreshold = 140.0;
  static const _processingInterval = Duration(milliseconds: 500);
  
  // Camera and detection components
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  final _recentReadings = <double>[];
  DateTime? _lastProcessingTime;
  
  // State management
  bool _isInitialized = false;
  final bool _isPermissionDenied = false;
  double? _sugarLevel;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFaceDetection();
    _requestCameraPermission();
  }

  void _initializeFaceDetection() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: true,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed && _cameraController == null) {
      _initializeCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    status.isGranted ? _initializeCamera() : _handlePermissionDenied();
  }

  void _handlePermissionDenied() {
    if (mounted) setState(() => openAppSettings());
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras available');

      _cameraController = CameraController(
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front),
        ResolutionPreset.low,
      );

      await _cameraController!.initialize();
      _startImageStream();
      
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      _handleCameraError(e);
    }
  }

  void _startImageStream() {
    _cameraController!.startImageStream((image) async {
      if (_shouldSkipProcessing()) return;
      await _processImage(image);
    });
  }

  bool _shouldSkipProcessing() {
    return _lastProcessingTime != null && 
        DateTime.now().difference(_lastProcessingTime!) < _processingInterval;
  }

  Future<void> _processImage(CameraImage image) async {
    _lastProcessingTime = DateTime.now();
    
    try {
      final simulatedValue = _simulateSugarLevel();
      _updateReadings(simulatedValue);
      
      if (mounted) {
        setState(() => _sugarLevel = _calculateAverageReading());
      }
    } catch (e) {
      _handleProcessingError(e);
    }
  }

  void _updateReadings(double value) {
    _recentReadings.add(value);
    if (_recentReadings.length > _maxReadings) _recentReadings.removeAt(0);
  }

  double _calculateAverageReading() {
    return _recentReadings.reduce((a, b) => a + b) / _recentReadings.length;
  }

  void _handleCameraError(dynamic error) {
    if (mounted) {
      setState(() {
        _errorMessage = 'Camera error: ${error.toString()}';
        _isInitialized = false;
      });
      _scheduleErrorClearance();
    }
  }

  void _handleProcessingError(dynamic error) {
    if (mounted && _errorMessage == null) {
      setState(() => _errorMessage = 'Processing error: ${error.toString()}');
      _scheduleErrorClearance();
    }
  }

  void _scheduleErrorClearance() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  double _simulateSugarLevel() {
    final base = 80 + math.Random().nextDouble() * 100;
    return base.clamp(70.0, 220.0).toDouble();
  }

  Future<void> _restartCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    await _initializeCamera();
  }

  void _stopCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose Level Simulation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartCamera,
            tooltip: 'Restart Camera',
          )
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (_isPermissionDenied) return _buildPermissionDeniedUI();
    if (_errorMessage != null) return _buildErrorUI();
    if (!_isInitialized) return _buildLoadingUI();
    return _buildMainInterface();
  }

  Widget _buildMainInterface() {
    return Column(
      children: [
        Expanded(child: _buildCameraPreview()),
        Expanded(child: _buildResultsPanel()),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            _buildFaceGuideOverlay(),
            if (_errorMessage != null) _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPanel() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _sugarLevel != null 
          ? _buildResultsCard()
          : _buildProcessingIndicator(),
    );
  }

  Widget _buildPermissionDeniedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Camera Access Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enable camera access in your device settings '
              'to use this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: openAppSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _restartCamera,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing Camera...'),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _errorMessage ?? 'Error',
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Analyzing Eye Patterns...'),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final isNormal = _sugarLevel! < _normalThreshold;
    
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHeader(isNormal),
            const SizedBox(height: 20),
            _buildBloodSugarDisplay(),
            const SizedBox(height: 20),
            _buildHealthAdvice(isNormal),
            const SizedBox(height: 20),
            _buildDisclaimerText(),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceGuideOverlay() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget _buildResultHeader(bool isNormal) {
    return Row(
      children: [
        Icon(
          isNormal ? Icons.check_circle : Icons.warning,
          color: isNormal ? Colors.green : Colors.orange,
          size: 40,
        ),
        const SizedBox(width: 16),
        Text(
          isNormal ? 'Normal Reading' : 'Elevated Reading',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isNormal ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodSugarDisplay() {
    return Column(
      children: [
        const Text(
          'Blood Glucose Level',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          '${_sugarLevel?.toStringAsFixed(1) ?? '--'} mg/dL',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthAdvice(bool isNormal) {
    return Text(
      isNormal
          ? 'Maintain healthy habits with regular exercise\nand balanced nutrition.'
          : 'Consult a healthcare professional for\npersonalized medical advice.',
      style: TextStyle(
        fontSize: 16,
        color: isNormal ? Colors.green : Colors.orange,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDisclaimerText() {
    return const Text(
      'Important: This simulation demonstrates potential functionality '
      'and should not be used for medical diagnosis. Always consult '
      'a healthcare professional for accurate blood glucose monitoring.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}