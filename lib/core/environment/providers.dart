// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/boot/providers.dart';
import '../../foundation/info/device_info.dart';
import '../../foundation/info/package_info.dart';
import '../../foundation/platform.dart' as app_platform;
import '../settings/providers.dart';
import 'data.dart';
import 'types.dart';

export 'data.dart';
export 'types.dart';

//FIXME: Need to set this from build.
const _kReleaseChannel = String.fromEnvironment('RELEASE_CHANNEL');

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  final deviceInfo = ref.watch(deviceInfoProvider);

  return AppEnvironment(
    appVersion: ref.watch(appVersionProvider),
    platform: app_platform.currentAppPlatform(),
    build: currentAppBuild(
      isFoss: ref.watch(isFossBuildProvider),
      environment: ref.watch(currentEnvironmentProvider),
    ),
    channel: currentReleaseChannel(
      releaseChannel: _kReleaseChannel,
    ),
    mode: currentFlutterMode(),
    device: currentDeviceKind(deviceInfo),
    languages: currentAppLanguages(
      appLanguage: ref.watch(settingsProvider.select((s) => s.language)),
      deviceInfo: deviceInfo,
      platformLanguages: PlatformDispatcher.instance.locales.map(
        _localeToLanguageTag,
      ),
    ),
    os: currentAppOsInfo(deviceInfo),
  );
});

String _localeToLanguageTag(Locale locale) {
  final countryCode = locale.countryCode;
  if (countryCode == null || countryCode.isEmpty) {
    return locale.languageCode;
  }

  return '${locale.languageCode}-$countryCode';
}
