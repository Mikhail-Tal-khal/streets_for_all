// // ignore_for_file: avoid_print

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:diabetes_test/models/eye_analyzer.dart';
// import 'package:diabetes_test/services/eye_camera_service.dart';
// import 'package:diabetes_test/test_results_provider.dart';

// class EyeAnalysisProvider with ChangeNotifier {
//   // Services
//   final EyeCameraService _cameraService = EyeCameraService();
//   final EyeAnalyzer _eyeAnalyzer = EyeAnalyzer();
//   final TestResultsProvider _resultsProvider;

//   // State variables
//   bool _isInitialized = false;
//   bool _isModelLoaded = false;
//   bool _isProcessing = false;
//   bool _isCapturing = false;
//   String? _errorMessage;
//   double _imageQuality = 0.0;

//   // Analysis results
//   Map<String, dynamic>? _analysisResults;

//   // Stream subscriptions
//   StreamSubscription? _qualityStreamSubscription;
//   StreamSubscription? _errorStreamSubscription;
//   StreamSubscription? _frameAnalysisSubscription;

//   // Constructor with TestResultsProvider dependency
//   EyeAnalysisProvider(this._resultsProvider);

//   // Getters
//   bool get isInitialized => _isInitialized;
//   bool get isModelLoaded => _isModelLoaded;
//   bool get isProcessing => _isProcessing;
//   bool get isCapturing => _isCapturing;
//   String? get errorMessage => _errorMessage;
//   double get imageQuality => _imageQuality;
//   Map<String, dynamic>? get analysisResults => _analysisResults;
//   EyeCameraService get cameraService => _cameraService;

//   // Initialize services
//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       // Load the TensorFlow model
//       await _loadModel();

//       // Initialize the camera service
//       await _initializeCamera();

//       _isInitialized = true;
//       notifyListeners();
//     } catch (e) {
//       _setError('Initialization error: $e');
//     }
//   }

//   // Load the AI model
//   Future<void> _loadModel() async {
//     try {
//       setState(() => _isModelLoaded = false);

//       await _eyeAnalyzer.loadModel();

//       setState(() => _isModelLoaded = true);
//     } catch (e) {
//       _setError('Failed to load AI model: $e');
//       rethrow;
//     }
//   }

//   // Initialize the camera
//   Future<void> _initializeCamera() async {
//     try {
//       // Initialize the camera service
//       await _cameraService.initializeCamera(
//         resolution: ResolutionPreset.high,
//         lensDirection: CameraLensDirection.back,
//       );

//       // Set up stream subscriptions
//       _setupStreamSubscriptions();
//     } catch (e) {
//       _setError('Camera initialization error: $e');
//       rethrow;
//     }
//   }

//   // Set up stream subscriptions
//   void _setupStreamSubscriptions() {
//     // Image quality stream
//     _qualityStreamSubscription = _cameraService.imageQualityStream.listen((
//       quality,
//     ) {
//       setState(() => _imageQuality = quality);
//     });

//     // Error stream
//     _errorStreamSubscription = _cameraService.errorStream.listen((error) {
//       _setError(error);
//     });

//     // Frame analysis stream (for real-time processing)
//     _frameAnalysisSubscription = _cameraService.frameAnalysisStream.listen((
//       image,
//     ) {
//       if (!_isProcessing && !_isCapturing && _isModelLoaded) {
//         _processFrame(image);
//       }
//     });
//   }

//   // Process a camera frame
//   Future<void> _processFrame(CameraImage image) async {
//     // Set processing flag to avoid overlapping analyses
//     setState(() => _isProcessing = true);

//     try {
//       // Analyze the camera frame
//       final results = await _eyeAnalyzer.analyzeCameraImage(image);

//       // Update with results
//       setState(() {
//         _analysisResults = results;
//         _isProcessing = false;
//       });
//     } catch (e) {
//       // Clear processing flag on error
//       setState(() => _isProcessing = false);

//       // Don't show errors during frame processing to avoid flooding the UI
//       print('Frame analysis error: $e');
//     }
//   }

//   // Capture and analyze a high-quality image
//   Future<Map<String, dynamic>?> captureAndAnalyze() async {
//     if (_isCapturing || !_isModelLoaded) return null;

//     // Set capturing flag
//     setState(() {
//       _isCapturing = true;
//       _errorMessage = null;
//     });

//     try {
//       // Capture high-quality image
//       final imageFile = await _cameraService.captureHighQualityImage();

//       if (imageFile == null) {
//         throw Exception('Failed to capture image');
//       }

//       // Analyze the captured image
//       final results = await _eyeAnalyzer.analyzeEyeImage(imageFile);

//       // Update with results
//       setState(() {
//         _analysisResults = results;
//         _isCapturing = false;
//       });

//       // Save the result if it's a valid analysis
//       if (results.containsKey('sugarEstimate')) {
//         await _saveTestResult(results);
//       }

//       return results;
//     } catch (e) {
//       setState(() {
//         _isCapturing = false;
//         _errorMessage = 'Analysis failed: $e';
//       });

//       return null;
//     }
//   }

//   // Save test result to the database
//   Future<void> _saveTestResult(Map<String, dynamic> results) async {
//     try {
//       await _resultsProvider.saveTestResult(results['sugarEstimate'] ?? 0.0, results['heartRate'] ?? 0);
//     } catch (e) {
//       print('Error saving test result: $e');
//       // Don't throw or set error, as this is non-critical
//     }
//   }

//   // Toggle flash mode
//   Future<FlashMode> toggleFlash() async {
//     try {
//       return await _cameraService.toggleFlash();
//     } catch (e) {
//       _setError('Failed to toggle flash: $e');
//       return FlashMode.auto;
//     }
//   }

//   // Set focus point
//   Future<void> setFocusPoint(Offset point) async {
//     try {
//       await _cameraService.setFocusPoint(point);
//     } catch (e) {
//       _setError('Failed to set focus point: $e');
//     }
//   }

//   // Restart camera
//   Future<void> restartCamera() async {
//     try {
//       await _stopCamera();
//       await _initializeCamera();
//       notifyListeners();
//     } catch (e) {
//       _setError('Failed to restart camera: $e');
//     }
//   }

//   // Stop camera
//   Future<void> _stopCamera() async {
//     // Cancel all stream subscriptions
//     _qualityStreamSubscription?.cancel();
//     _errorStreamSubscription?.cancel();
//     _frameAnalysisSubscription?.cancel();

//     // Dispose camera service
//     _cameraService.dispose();
//   }

//   // Set error message
//   void _setError(String error) {
//     setState(() => _errorMessage = error);

//     // Clear error after a delay
//     Future.delayed(const Duration(seconds: 5), () {
//       if (_errorMessage == error) {
//         setState(() => _errorMessage = null);
//       }
//     });
//   }

//   // Helper to update state and notify listeners
//   void setState(VoidCallback fn) {
//     fn();
//     notifyListeners();
//   }

//   // Dispose resources
//   @override
//   void dispose() {
//     _stopCamera();
//     _eyeAnalyzer.dispose();
//     super.dispose();
//   }
// }
