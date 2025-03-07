import 'package:flutter/services.dart';

/// A utility class for providing haptic feedback
class VibrationFeedback {
  /// Trigger a light impact feedback
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Trigger a medium impact feedback
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Trigger a heavy impact feedback
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Trigger a selection click feedback
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Trigger a vibration pattern
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
