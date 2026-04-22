// Conditional import resolves to stub on mobile, web impl on web
import 'haptic_service_stub.dart'
    if (dart.library.js_interop) 'haptic_service_web.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticService {
  HapticService._();

  static Future<void> selection() async {
    if (kIsWeb) {
      await WebHapticsImpl.trigger('selection');
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> light() async {
    if (kIsWeb) {
      await WebHapticsImpl.trigger('light');
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (kIsWeb) {
      await WebHapticsImpl.trigger('medium');
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> success() async {
    if (kIsWeb) {
      await WebHapticsImpl.trigger('success');
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> error() async {
    if (kIsWeb) {
      await WebHapticsImpl.trigger('error');
    } else {
      await HapticFeedback.heavyImpact();
    }
  }
}