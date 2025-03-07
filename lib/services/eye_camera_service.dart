
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EyeCameraService {
  /// Camera controller instance
  CameraController? _cameraController;
  
  /// Whether the camera is initialized
  bool _isInitialized = false;
  
  /// Stream controller for image quality
  final _imageQualityStreamController = StreamController<double>.broadcast();
  
  /// Stream controller for camera frame analysis
  final _frameAnalysisStreamController = StreamController<CameraImage>.broadcast();
  
  /// Stream controller for camera errors
  final _errorStreamController = StreamController<String>.broadcast();
  
  /// Last processed time to control processing rate
  DateTime? _lastProcessedTime;
  
  /// Stream controllers for external access
  Stream<double> get imageQualityStream => _imageQualityStreamController.stream;
  Stream<CameraImage> get frameAnalysisStream => _frameAnalysisStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;
  
  /// Get camera controller
  CameraController? get cameraController => _cameraController;
  
  /// Get whether camera is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the camera
  Future<void> initializeCamera({
    ResolutionPreset resolution = ResolutionPreset.veryHigh,
    CameraLensDirection lensDirection = CameraLensDirection.back,
  }) async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('No cameras available', 'No cameras were found on the device');
      }
      
      // Select camera by lens direction
      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => cameras.first,
      );
      
      // Initialize controller
      _cameraController = CameraController(
        selectedCamera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize the controller
      await _cameraController!.initialize();
      
      // Set advanced camera settings
      await _configureCameraSettings();
      
      _isInitialized = true;
      
      // Start image stream
      await startImageStream();
      
      return;
    } on CameraException catch (e) {
      _handleCameraError('Camera initialization error: ${e.description}');
    } catch (e) {
      _handleCameraError('Camera initialization error: $e');
    }
  }
  
  /// Configure optimal camera settings for eye imaging
  Future<void> _configureCameraSettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      // Lock capture orientation to portrait
      await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      // Set focus mode to auto if available
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Focus mode not supported, ignore
      }
      
      // Set flash mode based on environment
      await _cameraController!.setFlashMode(FlashMode.auto);
      
      // Set exposure mode to auto if available
      try {
        await _cameraController!.setExposureMode(ExposureMode.auto);
      } catch (e) {
        // Exposure mode not supported, ignore
      }
    } catch (e) {
      _handleCameraError('Error configuring camera settings: $e');
    }
  }
  
  /// Start the camera image stream
  Future<void> startImageStream() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _handleCameraError('Camera not initialized');
      return;
    }
    
    try {
      // Set processing interval (process frames at 10fps)
      const processingInterval = Duration(milliseconds: 100);
      
      // Start the image stream
      await _cameraController!.startImageStream((image) {
        // Control processing rate
        final now = DateTime.now();
        if (_lastProcessedTime != null &&
            now.difference(_lastProcessedTime!) < processingInterval) {
          return;
        }
        _lastProcessedTime = now;
        
        // Check image quality
        final quality = _assessImageQuality(image);
        _imageQualityStreamController.add(quality);
        
        // Only send good quality frames for analysis
        if (quality > 0.7) {
          _frameAnalysisStreamController.add(image);
        }
      });
    } catch (e) {
      _handleCameraError('Error starting image stream: $e');
    }
  }
  
  /// Stop the camera image stream
  Future<void> stopImageStream() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (e) {
      _handleCameraError('Error stopping image stream: $e');
    }
  }
  
  /// Capture a high quality eye image
  Future<XFile?> captureHighQualityImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _handleCameraError('Camera not initialized');
      return null;
    }
    
    try {
      // Stop streaming for better capture quality
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      
      // Wait a moment for the camera to stabilize
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Capture image
      final XFile file = await _cameraController!.takePicture();
      
      // Restart image stream
      await startImageStream();
      
      return file;
    } catch (e) {
      _handleCameraError('Error capturing image: $e');
      return null;
    }
  }
  
  /// Assess image quality for eye detection
  /// Returns a value between 0 (poor) and 1 (excellent)
  double _assessImageQuality(CameraImage image) {
    // Simple brightness assessment
    final luminance = _calculateAverageLuminance(image);
    
    // Calculate quality score based on multiple factors
    double brightnessScore = 0.0;
    
    // Optimal brightness range for eye imaging is around 120-180 (out of 255)
    if (luminance < 50) {
      // Too dark
      brightnessScore = luminance / 100;
    } else if (luminance > 220) {
      // Too bright
      brightnessScore = 1.0 - ((luminance - 220) / 35);
    } else {
      // Good brightness range
      brightnessScore = 0.7 + (0.3 * (1.0 - (Math.min(Math.abs(luminance - 150), 70) / 70)));
    }
    
    return brightnessScore.clamp(0.0, 1.0);
  }
  
  /// Calculate average luminance from a camera image
  double _calculateAverageLuminance(CameraImage image) {
    // For YUV_420 format, Y plane is luminance
    if (image.format.group == ImageFormatGroup.yuv420) {
      final yPlane = image.planes[0].bytes;
      double sum = 0;
      
      // Sample every 16th pixel for efficiency
      for (int i = 0; i < yPlane.length; i += 16) {
        sum += yPlane[i];
      }
      
      return sum / (yPlane.length / 16);
    }
    
    // For other formats, return middle value as fallback
    return 128.0;
  }
  
  /// Handle camera errors
  void _handleCameraError(String errorMessage) {
    debugPrint(errorMessage);
    _errorStreamController.add(errorMessage);
  }
  
  /// Check if flash is supported
  bool get isFlashSupported => 
      _cameraController != null && 
      _cameraController!.value.isInitialized;
  
  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      await _cameraController!.setFlashMode(mode);
    } catch (e) {
      _handleCameraError('Error setting flash mode: $e');
    }
  }
  
  /// Toggle flash mode
  Future<FlashMode> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return FlashMode.auto;
    }
    
    try {
      FlashMode newMode;
      switch (_cameraController!.value.flashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        default:
          newMode = FlashMode.off;
      }
      
      await _cameraController!.setFlashMode(newMode);
      return newMode;
    } catch (e) {
      _handleCameraError('Error toggling flash: $e');
      return FlashMode.auto;
    }
  }
  
  /// Focus on a specific point
  Future<void> setFocusPoint(Offset point) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      await _cameraController!.setFocusPoint(point);
      
      // Try to set focus mode to locked after setting point
      try {
        await _cameraController!.setFocusMode(FocusMode.locked);
        
        // After a moment, return to auto focus
        await Future.delayed(const Duration(seconds: 2));
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Focus mode not supported, ignore
      }
    } catch (e) {
      _handleCameraError('Error setting focus point: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopImageStream();
    
    _cameraController?.dispose();
    _cameraController = null;
    
    _imageQualityStreamController.close();
    _frameAnalysisStreamController.close();
    _errorStreamController.close();
    
    _isInitialized = false;
  }
}

/// Math utilities
class Math {
  static double min(double a, double b) => a < b ? a : b;
  static double max(double a, double b) => a > b ? a : b;
  static double abs(double a) => a < 0 ? -a : a;
}