// Flutter imports:
import 'package:flutter/services.dart';

Future<void> hideSystemStatus() => SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.immersiveSticky,
);

Future<void> showSystemStatus() => SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.edgeToEdge,
);

Future<void> setDeviceToLandscapeMode() =>
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft],
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
}) => active ? showSystemStatus() : hideSystemStatus();
