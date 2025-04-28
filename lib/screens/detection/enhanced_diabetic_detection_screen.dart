// // lib/screens/detection/enhanced_diabetic_detection_screen.dart

// // ignore_for_file: avoid_print, deprecated_member_use

// import 'dart:async';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:diabetes_test/models/eye_analyzer.dart';
// import 'package:diabetes_test/services/eye_camera_service.dart';
// import 'package:diabetes_test/test_results_provider.dart';

// class EnhancedDiabeticDetectionScreen extends StatefulWidget {
//   const EnhancedDiabeticDetectionScreen({super.key});

//   @override
//   State<EnhancedDiabeticDetectionScreen> createState() => _EnhancedDiabeticDetectionScreenState();
// }

// class _EnhancedDiabeticDetectionScreenState extends State<EnhancedDiabeticDetectionScreen> 
//     with WidgetsBindingObserver, TickerProviderStateMixin {
  
//   // Services
//   final EyeCameraService _cameraService = EyeCameraService();
//   final EyeAnalyzer _eyeAnalyzer = EyeAnalyzer();
  
//   // State variables
//   bool _isInitialized = false;
//   bool _isPermissionDenied = false;
//   bool _isProcessing = false;
//   bool _isModelLoading = true;
//   bool _isCapturing = false;
//   String? _errorMessage;
  
//   // Analysis results
//   Map<String, dynamic>? _analysisResults;
//   double _imageQuality = 0.0;
  
//   // Animation controllers
//   late AnimationController _pulseAnimationController;
//   late Animation<double> _pulseAnimation;
  
//   // Stream subscriptions
//   StreamSubscription? _qualityStreamSubscription;
//   StreamSubscription? _errorStreamSubscription;
//   StreamSubscription? _frameAnalysisSubscription;
  
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
    
//     // Initialize UI animations
//     _initializeAnimations();
    
//     // Request camera permission and initialize
//     _requestCameraPermission();
    
//     // Load the TensorFlow model
//     _loadModel();
//   }
  
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Handle app lifecycle changes
//     if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
//       _stopCamera();
//     } else if (state == AppLifecycleState.resumed) {
//       if (!_isInitialized && !_isPermissionDenied) {
//         _initializeCamera();
//       }
//     }
//   }
  
//   void _initializeAnimations() {
//     // Pulse animation for the capture guide
//     _pulseAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
    
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
//       CurvedAnimation(
//         parent: _pulseAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }
  
//   Future<void> _loadModel() async {
//     try {
//       setState(() => _isModelLoading = true);
      
//       await _eyeAnalyzer.loadModel();
      
//       setState(() => _isModelLoading = false);
//     } catch (e) {
//       setState(() {
//         _isModelLoading = false;
//         _errorMessage = 'Failed to load AI model: $e';
//       });
      
//       _scheduleErrorClearance();
//     }
//   }
  
//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
    
//     if (status.isGranted) {
//       _initializeCamera();
//     } else {
//       setState(() => _isPermissionDenied = true);
//     }
//   }
  
//   Future<void> _initializeCamera() async {
//     try {
//       // Initialize the camera service
//       await _cameraService.initializeCamera(
//         resolution: ResolutionPreset.high,
//         lensDirection: CameraLensDirection.back,
//       );
      
//       // Set up stream subscriptions
//       _setupStreamSubscriptions();
      
//       setState(() => _isInitialized = true);
//     } catch (e) {
//       _handleError('Camera initialization error: $e');
//     }
//   }
  
//   void _setupStreamSubscriptions() {
//     // Image quality stream
//     _qualityStreamSubscription = _cameraService.imageQualityStream.listen((quality) {
//       setState(() => _imageQuality = quality);
//     });
    
//     // Error stream
//     _errorStreamSubscription = _cameraService.errorStream.listen((error) {
//       _handleError(error);
//     });
    
//     // Frame analysis stream (for real-time processing)
//     _frameAnalysisSubscription = _cameraService.frameAnalysisStream.listen((image) {
//       if (!_isProcessing && !_isCapturing && _eyeAnalyzer.isModelLoaded) {
//         _processFrame(image);
//       }
//     });
//   }
  
//   Future<void> _processFrame(CameraImage image) async {
//     // Set processing flag to avoid overlapping analyses
//     setState(() => _isProcessing = true);
    
//     try {
//       // Analyze the camera frame
//       final results = await _eyeAnalyzer.analyzeCameraImage(image);
      
//       // Update UI with results
//       setState(() {
//         _analysisResults = results;
//         _isProcessing = false;
//       });
//     } catch (e) {
//       // Clear processing flag on error
//       setState(() => _isProcessing = false);
      
//       // Do not show errors during frame processing to avoid flooding the UI
//       print('Frame analysis error: $e');
//     }
//   }
  
//   Future<void> _captureAndAnalyze() async {
//     if (_isCapturing || _isModelLoading) return;
    
//     // Set capturing flag
//     setState(() {
//       _isCapturing = true;
//       _errorMessage = null;
//     });
    
//     try {
//       // Provide haptic feedback
//       HapticFeedback.mediumImpact();
      
//       // Capture high-quality image
//       final imageFile = await _cameraService.captureHighQualityImage();
      
//       if (imageFile == null) {
//         throw Exception('Failed to capture image');
//       }
      
//       // Analyze the captured image
//       final results = await _eyeAnalyzer.analyzeEyeImage(imageFile);
      
//       // Update UI with results
//       setState(() {
//         _analysisResults = results;
//         _isCapturing = false;
//       });
      
//       // Save the result if it's a valid analysis
//       if (results.containsKey('sugarEstimate')) {
//         await _saveTestResult(results);
        
//         // Navigate to results screen
//         _navigateToResultsScreen(results);
//       }
//     } catch (e) {
//       setState(() {
//         _isCapturing = false;
//         _errorMessage = 'Analysis failed: $e';
//       });
      
//       _scheduleErrorClearance();
//     }
//   }
  
//   Future<void> _saveTestResult(Map<String, dynamic> results) async {
//     try {
//       final resultsProvider = Provider.of<TestResultsProvider>(context, listen: false);
      
//       await resultsProvider.saveTestResult(
//         results['sugarEstimate'] ?? 0.0,
//         results['heartRate'] ?? 0,
//       );
//     } catch (e) {
//       // Don't show an error to the user for this, as it's not critical
//     }
//   }
  
//   void _navigateToResultsScreen(Map<String, dynamic> results) {
//     Navigator.of(context).pop(results);
//   }
  
//   void _handleError(String error) {
//     setState(() => _errorMessage = error);
//     _scheduleErrorClearance();
//   }
  
//   void _scheduleErrorClearance() {
//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() => _errorMessage = null);
//       }
//     });
//   }
  
//   Future<void> _stopCamera() async {
//     // Cancel all stream subscriptions
//     _qualityStreamSubscription?.cancel();
//     _errorStreamSubscription?.cancel();
//     _frameAnalysisSubscription?.cancel();
    
//     // Dispose camera service
//     _cameraService.dispose();
    
//     setState(() => _isInitialized = false);
//   }
  
//   Future<void> _restartCamera() async {
//     await _stopCamera();
//     await _initializeCamera();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Retina Analysis'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: _showInfoDialog,
//             tooltip: 'How It Works',
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _restartCamera,
//             tooltip: 'Restart Camera',
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }
  
//   Widget _buildBody() {
//     if (_isPermissionDenied) {
//       return _buildPermissionDeniedUI();
//     }
    
//     if (_errorMessage != null && !_isInitialized) {
//       return _buildErrorUI();
//     }
    
//     if (_isModelLoading) {
//       return _buildLoadingModelUI();
//     }
    
//     if (!_isInitialized) {
//       return _buildLoadingCameraUI();
//     }
    
//     return Column(
//       children: [
//         Expanded(
//           flex: 6,
//           child: _buildCameraPreviewSection(),
//         ),
//         Expanded(
//           flex: 4,
//           child: _buildResultsSection(),
//         ),
//       ],
//     );
//   }
  
//   Widget _buildPermissionDeniedUI() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.camera_alt, size: 72, color: Colors.grey),
//             const SizedBox(height: 24),
//             const Text(
//               'Camera Access Required',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Please grant camera permission to use the eye scanning feature. '
//               'This is required to analyze your retina for diabetic signs.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => openAppSettings(),
//               child: const Text('Open Settings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildErrorUI() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, size: 72, color: Colors.red),
//             const SizedBox(height: 24),
//             const Text(
//               'Error',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _errorMessage ?? 'An unknown error occurred.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _restartCamera,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildLoadingModelUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).colorScheme.primary,
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Loading AI Analysis Model',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Please wait while we prepare the AI model\nfor analyzing your eye scans.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildLoadingCameraUI() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Initializing Camera...'),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildCameraPreviewSection() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Camera preview
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: _cameraService.cameraController != null
//                 ? CameraPreview(_cameraService.cameraController!)
//                 : Container(color: Colors.black),
//           ),
          
//           // Guide overlay
//           Center(
//             child: AnimatedBuilder(
//               animation: _pulseAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _pulseAnimation.value,
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _getGuideColor(),
//                         width: 3,
//                       ),
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
          
//           // Quality indicator
//           Positioned(
//             top: 12,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   _getQualityText(),
//                   style: TextStyle(
//                     color: _getQualityColor(),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
          
//           // Error overlay
//           if (_errorMessage != null)
//             Positioned(
//               bottom: 12,
//               left: 12,
//               right: 12,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.white),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
          
//           // Capture button
//           Positioned(
//             bottom: 20,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: _buildCaptureButton(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildCaptureButton() {
//     return GestureDetector(
//       onTap: _isCapturing || _isModelLoading ? null : _captureAndAnalyze,
//       child: Container(
//         width: 70,
//         height: 70,
//         decoration: BoxDecoration(
//           color: _isCapturing || _isModelLoading
//               ? Colors.grey
//               : Theme.of(context).colorScheme.primary,
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: _isCapturing || _isModelLoading
//             ? const CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               )
//             : const Icon(
//                 Icons.camera_alt,
//                 color: Colors.white,
//                 size: 32,
//               ),
//       ),
//     );
//   }
  
//   Widget _buildResultsSection() {
//     if (_analysisResults == null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.remove_red_eye_outlined,
//                 size: 48,
//                 color: Colors.blue,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Position your eye within the circle',
//                 style: Theme.of(context).textTheme.headlineSmall,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Hold the camera 15-20 cm from your eye',
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }
    
//     // Show real-time analysis results
//     final isNormal = _analysisResults!['isNormal'] ?? true;
//     final severity = _analysisResults!['severity'] ?? 'No DR';
//     final sugarEstimate = _analysisResults!['sugarEstimate']?.toStringAsFixed(1) ?? '--';
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 isNormal ? Icons.check_circle : Icons.warning,
//                 color: isNormal ? Colors.green : Colors.orange,
//                 size: 30,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 isNormal ? 'Normal Reading' : 'Elevated Reading',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: isNormal ? Colors.green : Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildInfoCard(
//                   'Estimated Blood Glucose',
//                   '$sugarEstimate mg/dL',
//                   icon: Icons.bloodtype,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildInfoCard(
//                   'Detection Result',
//                   severity,
//                   icon: Icons.visibility,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text(
//               'Note: This is a screening tool only. For accurate diagnosis, '
//               'please consult with a healthcare professional.',
//               style: TextStyle(
//                 fontStyle: FontStyle.italic,
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _captureAndAnalyze,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: const Text('Capture Final Result'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   Widget _buildInfoCard(String title, String value, {required IconData icon}) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Icon(icon, color: Theme.of(context).colorScheme.primary),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Color _getGuideColor() {
//     if (_imageQuality < 0.3) {
//       return Colors.red;
//     } else if (_imageQuality < 0.7) {
//       return Colors.yellow;
//     } else {
//       return Colors.green;
//     }
//   }
  
//   Color _getQualityColor() {
//     if (_imageQuality < 0.3) {
//       return Colors.red;
//     } else if (_imageQuality < 0.7) {
//       return Colors.yellow;
//     } else {
//       return Colors.green;
//     }
//   }
  
//   String _getQualityText() {
//     if (_imageQuality < 0.3) {
//       return 'Poor Image Quality';
//     } else if (_imageQuality < 0.7) {
//       return 'Acceptable Image Quality';
//     } else {
//       return 'Good Image Quality';
//     }
//   }
  
//   void _showInfoDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('How It Works'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Text(
//                 'This eye scanner uses AI to analyze patterns in your retina that may indicate early signs of diabetic retinopathy.',
//                 style: TextStyle(fontSize: 14),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 'For best results:',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//               ),
//               SizedBox(height: 8),
//               Text('• Hold the phone 15-20 cm from your eye'),
//               Text('• Keep your eye open and steady'),
//               Text('• Ensure good lighting conditions'),
//               Text('• Align your eye within the circle guide'),
//               SizedBox(height: 12),
//               Text(
//                 'The estimated blood glucose level is for screening purposes only and should not replace proper medical testing.',
//                 style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   @override
//   void dispose() {
//     // Cancel all stream subscriptions
//     _qualityStreamSubscription?.cancel();
//     _errorStreamSubscription?.cancel();
//     _frameAnalysisSubscription?.cancel();
    
//     // Dispose animation controllers
//     _pulseAnimationController.dispose();
    
//     // Dispose services
//     _cameraService.dispose();
//     _eyeAnalyzer.dispose();
    
//     WidgetsBinding.instance.removeObserver(this);
//       super.dispose();
//     }
//   }