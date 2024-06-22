// Flutter imports:
import 'package:flutter/services.dart';

Future<void> hideSystemStatus() => SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
      ],
    );

Future<void> showSystemStatus() => SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

Future<void> setDeviceToLandscapeMode() =>
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight],
    );

Future<void> setDeviceToPortraitMode() => SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );

Future<void> setDeviceToAutoRotateMode() =>
    SystemChrome.setPreferredOrientations(
      DeviceOrientation.values,
    );

Future<void> setSystemActiveStatus({
  required bool active,
}) =>
    active ? showSystemStatus() : hideSystemStatus();
