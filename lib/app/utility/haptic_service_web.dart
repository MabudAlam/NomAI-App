import 'package:web_haptics/web_haptics.dart';

class WebHapticsImpl {
  static WebHaptics? _instance;

  static WebHaptics get _haptics {
    _instance ??= WebHaptics();
    return _instance!;
  }

  static Future<void> trigger(String preset) async {
    try {
      _haptics.trigger(preset);
    } catch (_) {}
  }
}