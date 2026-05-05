// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import '../../foundation/info/device_info.dart';
import 'types.dart';

AppBuild currentAppBuild({
  required bool isFoss,
  required String environment,
}) {
  if (isFoss) return AppBuild.foss;
  if (environment.toLowerCase() == 'dev') return AppBuild.dev;

  return AppBuild.standard;
}

ReleaseChannel currentReleaseChannel({
  required String releaseChannel,
}) {
  return releaseChannelFrom(releaseChannel);
}

FlutterMode currentFlutterMode() {
  if (kDebugMode) return FlutterMode.debug;
  if (kProfileMode) return FlutterMode.profile;

  return FlutterMode.release;
}

DeviceKind currentDeviceKind(DeviceInfo deviceInfo) {
  final androidInfo = deviceInfo.androidDeviceInfo;
  if (androidInfo != null) {
    return androidInfo.isPhysicalDevice
        ? DeviceKind.physical
        : DeviceKind.virtual;
  }

  final iosInfo = deviceInfo.iosDeviceInfo;
  if (iosInfo != null) {
    return iosInfo.isPhysicalDevice ? DeviceKind.physical : DeviceKind.virtual;
  }

  return DeviceKind.unknown;
}

List<String> currentAppLanguages({
  required String appLanguage,
  required DeviceInfo deviceInfo,
  required Iterable<String> platformLanguages,
}) {
  final languages = <String>[
    appLanguage,
    ...platformLanguages,
  ];

  final webInfo = deviceInfo.webBrowserInfo;
  if (webInfo != null) {
    final language = webInfo.language;
    if (language != null) {
      languages.add(language);
    }

    languages.addAll(webInfo.languages?.whereType<String>() ?? const []);
  }

  final normalizedLanguages = <String>[];
  final seen = <String>{};

  for (final language in languages) {
    final normalizedLanguage = _normalizeLanguageTag(language);
    if (normalizedLanguage.isEmpty) continue;

    if (seen.add(normalizedLanguage)) {
      normalizedLanguages.add(normalizedLanguage);
    }
  }

  return normalizedLanguages;
}

AppOsInfo currentAppOsInfo(DeviceInfo deviceInfo) {
  final androidInfo = deviceInfo.androidDeviceInfo;
  if (androidInfo != null) {
    return AppOsInfo(
      androidSdk: androidInfo.version.sdkInt,
      version: Version.tryParse(androidInfo.version.release),
    );
  }

  final iosInfo = deviceInfo.iosDeviceInfo;
  if (iosInfo != null) {
    return AppOsInfo(
      version: Version.tryParse(iosInfo.systemVersion),
    );
  }

  final macOsInfo = deviceInfo.macOsDeviceInfo;
  if (macOsInfo != null) {
    return AppOsInfo(
      version: Version(
        macOsInfo.majorVersion,
        macOsInfo.minorVersion,
        macOsInfo.patchVersion,
      ),
    );
  }

  final windowsInfo = deviceInfo.windowsDeviceInfo;
  if (windowsInfo != null) {
    return AppOsInfo(
      version: Version(
        windowsInfo.majorVersion,
        windowsInfo.minorVersion,
        windowsInfo.buildNumber,
      ),
    );
  }

  final linuxInfo = deviceInfo.linuxDeviceInfo;
  if (linuxInfo != null) {
    return AppOsInfo(
      version: Version.tryParse(linuxInfo.versionId ?? linuxInfo.version ?? ''),
      linuxDistros: {
        linuxInfo.id.toLowerCase(),
        for (final id in linuxInfo.idLike ?? const <String>[]) id.toLowerCase(),
      },
      linuxVersionId: linuxInfo.versionId?.toLowerCase(),
    );
  }

  final webInfo = deviceInfo.webBrowserInfo;
  if (webInfo != null) {
    return AppOsInfo(
      browser: webInfo.browserName.name.toLowerCase(),
    );
  }

  return const AppOsInfo();
}

String _normalizeLanguageTag(String language) {
  return language.trim().replaceAll('_', '-').toLowerCase();
}
