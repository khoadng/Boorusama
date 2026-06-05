// Package imports:
import 'package:flutter_displaymode/flutter_displaymode.dart';

// Project imports:
import '../loggers.dart';
import '../platform.dart';

const _kServiceName = 'Display Mode';

typedef DisplayModePlatformCheck = bool Function();
typedef HighRefreshRateSetter = Future<void> Function();

class DisplayModeService {
  DisplayModeService({
    DisplayModePlatformCheck? isSupportedPlatform,
    HighRefreshRateSetter? setHighRefreshRate,
  }) : _isSupportedPlatform = isSupportedPlatform ?? isAndroid,
       _setHighRefreshRate =
           setHighRefreshRate ?? FlutterDisplayMode.setHighRefreshRate;

  final DisplayModePlatformCheck _isSupportedPlatform;
  final HighRefreshRateSetter _setHighRefreshRate;

  Future<void> preferHighRefreshRate({
    Logger? logger,
  }) async {
    if (!_isSupportedPlatform()) return;

    try {
      await _setHighRefreshRate();
      logger?.debug(_kServiceName, 'High refresh rate requested');
    } on Object catch (error) {
      logger?.warn(
        _kServiceName,
        'Failed to request high refresh rate: $error',
      );
    }
  }
}
