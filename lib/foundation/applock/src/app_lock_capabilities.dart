// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../platform.dart';

class AppLockCapabilities {
  const AppLockCapabilities({
    required this.deviceAuthentication,
    required this.nativePrivacyCover,
  });

  factory AppLockCapabilities.forPlatform(AppPlatform platform) {
    final deviceAuthentication = switch (platform) {
      AppPlatform.android ||
      AppPlatform.ios ||
      AppPlatform.macos ||
      AppPlatform.windows => true,
      AppPlatform.linux || AppPlatform.web || AppPlatform.unknown => false,
    };
    final nativePrivacyCover = switch (platform) {
      AppPlatform.ios || AppPlatform.macos || AppPlatform.windows => true,
      AppPlatform.android ||
      AppPlatform.linux ||
      AppPlatform.web ||
      AppPlatform.unknown => false,
    };

    return AppLockCapabilities(
      deviceAuthentication: deviceAuthentication,
      nativePrivacyCover: nativePrivacyCover,
    );
  }

  final bool deviceAuthentication;
  final bool nativePrivacyCover;
}

final appLockCapabilitiesProvider = Provider<AppLockCapabilities>(
  (ref) => AppLockCapabilities.forPlatform(currentAppPlatform()),
  name: 'appLockCapabilitiesProvider',
);
