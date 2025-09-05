// Package imports:
import 'package:fvp/fvp.dart' as fvp;

// Project imports:
import '../../../settings/settings.dart';

class FvpManager {
  factory FvpManager() => _instance;
  FvpManager._internal();

  static final _instance = FvpManager._internal();

  VideoPlayerEngine? _currentEngine;
  var _isInitialized = false;

  void ensureInitialized(VideoPlayerEngine engine) {
    if (_isInitialized && _currentEngine == engine) {
      return;
    }

    if (_isInitialized && _currentEngine != engine) {
      // Unregister previous engine
      fvp.registerWith(options: {'platforms': []});
    }

    // Register new engine
    fvp.registerWith(
      options: {
        'platforms': [
          'linux',
          'ios',
          'windows',
          'macos',
          if (engine == VideoPlayerEngine.mdk) 'android',
        ],
      },
    );

    _currentEngine = engine;
    _isInitialized = true;
  }

  void reset() {
    if (_isInitialized) {
      fvp.registerWith(options: {'platforms': []});
      _currentEngine = null;
      _isInitialized = false;
    }
  }
}
