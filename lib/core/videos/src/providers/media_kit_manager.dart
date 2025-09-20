// Package imports:
import 'package:media_kit/media_kit.dart';

class MediaKitManager {
  factory MediaKitManager() => _instance;
  MediaKitManager._internal();

  static final MediaKitManager _instance = MediaKitManager._internal();

  bool _isInitialized = false;

  void ensureInitialized() {
    if (_isInitialized) {
      return;
    }

    MediaKit.ensureInitialized();
    _isInitialized = true;
  }

  void reset() {
    // MediaKit doesn't provide a reset method, but we can track initialization state
    // The actual MediaKit instance will remain initialized for the app lifetime
    _isInitialized = false;
  }
}
