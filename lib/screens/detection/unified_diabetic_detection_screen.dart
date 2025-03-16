import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class UnifiedDiabeticDetectionScreen extends StatefulWidget {
  const UnifiedDiabeticDetectionScreen({super.key});

  @override
  State<UnifiedDiabeticDetectionScreen> createState() =>
      _UnifiedDiabeticDetectionScreenState();
}

class _UnifiedDiabeticDetectionScreenState
    extends State<UnifiedDiabeticDetectionScreen>
    with TickerProviderStateMixin {
  // Services
  late CameraService _cameraService;
  late EyeAnalyzer _eyeAnalyzer;
  late FaceDetector _faceDetector;

  // Controllers
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // State variables
  String _errorMessage = '';
  bool _isProcessing = false;
  bool _isCompleted = false;
  bool _hasError = false;
  double _imageQuality = 0.0;
  Map<String, dynamic>? _analysisResults;

  // Subscriptions
  StreamSubscription? _qualityStreamSubscription;
  StreamSubscription? _errorStreamSubscription;
  StreamSubscription? _frameAnalysisSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize services
    _cameraService = CameraService();
    _eyeAnalyzer = EyeAnalyzer();
    _faceDetector = FaceDetector();

    // Initialize animation controller for pulse effect
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);

    // Start camera and setup streams
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();

      // Listen to image quality updates
      _qualityStreamSubscription = _eyeAnalyzer.qualityStream.listen((quality) {
        setState(() {
          _imageQuality = quality / 100.0; // Convert to 0.0-1.0 scale
        });
      });

      // Listen to error messages
      _errorStreamSubscription = _eyeAnalyzer.errorStream.listen((error) {
        setState(() {
          _errorMessage = error;
          _hasError = error.isNotEmpty;
        });
      });

      // Listen to frame analysis results
      _frameAnalysisSubscription = _eyeAnalyzer.analysisStream.listen((
        results,
      ) {
        if (results != null) {
          setState(() {
            _isProcessing = false;
            _isCompleted = true;
            _analysisResults = results;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _hasError = true;
      });
    }
  }

  void _proceedToEyeAnalysis() {
    setState(() {
      _isProcessing = true;
    });

    _eyeAnalyzer.startAnalysis(_cameraService.cameraController);
  }

  void _restartScreening() {
    setState(() {
      _errorMessage = '';
      _hasError = false;
      _isCompleted = false;
      _isProcessing = false;
      _imageQuality = 0.0;
      _analysisResults = null;
    });
  }

  Color _getEyeAnalysisGuideColor() {
    if (_imageQuality < 0.3) {
      return Colors.red;
    } else if (_imageQuality < 0.7) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  Color _getImageQualityColor() {
    if (_imageQuality < 0.3) {
      return Colors.red;
    } else if (_imageQuality < 0.7) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  String _getImageQualityText() {
    if (_imageQuality < 0.3) {
      return 'Poor Image Quality';
    } else if (_imageQuality < 0.7) {
      return 'Acceptable Image Quality';
    } else {
      return 'Good Image Quality';
    }
  }

  @override
  void dispose() {
    _qualityStreamSubscription?.cancel();
    _errorStreamSubscription?.cancel();
    _frameAnalysisSubscription?.cancel();

    // Dispose animation controller
    _pulseAnimationController.dispose();

    // Dispose services
    _faceDetector.dispose();
    _cameraService.dispose();
    _eyeAnalyzer.dispose();

    super.dispose();
  }

  // Add info button to AppBar
  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return _buildProcessingUI();
    } else if (_isCompleted) {
      return _buildCompletedUI();
    } else if (_hasError) {
      return _buildErrorUI();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Eye Screening'),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showInfoDialog,
              tooltip: 'How it works',
            ),
          ],
        ),
        body: _buildEyeAnalysisBody(),
      );
    }
  }

  // The body of the eye analysis screen
  Widget _buildEyeAnalysisBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        if (_cameraService.isInitialized)
          CameraPreview(_cameraService.cameraController),

        // Semi-transparent overlay
        Container(color: Colors.black.withOpacity(0.3)),

        // Guide overlay
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getEyeAnalysisGuideColor(),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              );
            },
          ),
        ),

        // Instruction text
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Position eye within the circle',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Quality indicator
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getImageQualityText(),
                style: TextStyle(
                  color: _getImageQualityColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Error message
        if (_errorMessage.isNotEmpty)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

        // Bottom action buttons
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: _imageQuality >= 0.7 ? _proceedToEyeAnalysis : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text('Start Analysis'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyzing Eye'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Analyzing Eye Scan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please wait while we process your eye scan...',
              textAlign: TextAlign.center,
            ),
            if (_analysisResults != null) ...[
              const SizedBox(height: 24),
              Text(
                'Detected Severity: ${_analysisResults!['severity'] ?? 'Unknown'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Complete'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            Text(
              'Screening Complete',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your eye scan has been successfully processed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to results or home screen
                Navigator.of(context).pop();
              },
              child: const Text('View Results'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Scaffold(
      appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.teal),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 100),
              const SizedBox(height: 24),
              Text(
                'Screening Error',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage.isEmpty
                    ? 'An unexpected error occurred'
                    : _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _restartScreening,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('How It Works'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diabetic Screening Process',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Our AI-powered screening involves two key stages:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoStep(
                    '1. Face Detection',
                    'We first detect your face to ensure proper positioning and eye visibility.',
                    Icons.face,
                  ),
                  _buildInfoStep(
                    '2. Eye Scan',
                    'We then use advanced AI to analyze your eye for potential diabetic retinopathy signs.',
                    Icons.remove_red_eye,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Important Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• This is a screening tool, not a medical diagnosis',
                    style: TextStyle(fontSize: 14),
                  ),
                  const Text(
                    '• Always consult a healthcare professional',
                    style: TextStyle(fontSize: 14),
                  ),
                  const Text(
                    '• Results are for informational purposes only',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Understood'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoStep(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// These are placeholder classes for the services mentioned in the code
// You would need to implement these properly based on your app's requirements

class CameraService {
  bool isInitialized = false;
  late CameraController cameraController;

  Future<void> initialize() async {
    // Implement camera initialization
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController.initialize();
    isInitialized = true;
  }

  void dispose() {
    if (isInitialized) {
      cameraController.dispose();
    }
  }
}

class EyeAnalyzer {
  final StreamController<int> _qualityController =
      StreamController<int>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>?> _analysisController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<int> get qualityStream => _qualityController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>?> get analysisStream =>
      _analysisController.stream;

  void startAnalysis(CameraController controller) {
    // Implement eye analysis logic
    // You would process frames from the camera here
    // For demonstration, we'll just simulate quality updates and eventual results

    // Simulate quality updates
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      int quality = (timer.tick * 10).clamp(0, 100);
      _qualityController.add(quality);

      if (quality >= 100) {
        timer.cancel();

        // After a delay, deliver results
        Future.delayed(const Duration(seconds: 3), () {
          _analysisController.add({
            'severity': 'Mild',
            'confidence': 0.85,
            'recommendation': 'Follow up with your doctor within 3 months.',
          });
        });
      }
    });
  }

  void dispose() {
    _qualityController.close();
    _errorController.close();
    _analysisController.close();
  }
}

class FaceDetector {
  // Placeholder for face detection functionality
  void dispose() {
    // Clean up resources
  }
}
