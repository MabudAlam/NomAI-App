import 'package:flutter/services.dart';

class HapticService {
  const HapticService._();

  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }
}
