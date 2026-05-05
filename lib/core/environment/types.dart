// Package imports:
import 'package:coreutils/coreutils.dart';

// Project imports:
import '../../foundation/platform.dart';

class AppEnvironment {
  const AppEnvironment({
    required this.appVersion,
    required this.platform,
    required this.build,
    required this.channel,
    required this.mode,
    required this.device,
    required this.languages,
    required this.os,
  });

  final Version? appVersion;
  final AppPlatform platform;
  final AppBuild build;
  final ReleaseChannel channel;
  final FlutterMode mode;
  final DeviceKind device;
  final List<String> languages;
  final AppOsInfo os;

  @override
  String toString() {
    return [
      'appVersion=$appVersion',
      'platform=${platform.wireName}',
      'build=${build.wireName}',
      'channel=${channel.wireName}',
      'mode=${mode.wireName}',
      'device=${device.wireName}',
      'languages=${languages.join(',')}',
      'os=$os',
    ].join(' ');
  }
}

enum AppBuild {
  standard,
  foss,
  dev,
}

extension AppBuildX on AppBuild {
  String get wireName => switch (this) {
    AppBuild.standard => 'standard',
    AppBuild.foss => 'foss',
    AppBuild.dev => 'dev',
  };
}

enum ReleaseChannel {
  play,
  github,
  unknown,
}

extension ReleaseChannelX on ReleaseChannel {
  String get wireName => switch (this) {
    ReleaseChannel.play => 'play',
    ReleaseChannel.github => 'github',
    ReleaseChannel.unknown => 'unknown',
  };
}

ReleaseChannel releaseChannelFrom(String value) {
  final normalizedValue = value.trim().toLowerCase();

  for (final channel in ReleaseChannel.values) {
    if (channel.wireName == normalizedValue) return channel;
  }

  return ReleaseChannel.unknown;
}

enum FlutterMode {
  debug,
  profile,
  release,
}

extension FlutterModeX on FlutterMode {
  String get wireName => switch (this) {
    FlutterMode.debug => 'debug',
    FlutterMode.profile => 'profile',
    FlutterMode.release => 'release',
  };
}

enum DeviceKind {
  physical,
  virtual,
  unknown,
}

extension DeviceKindX on DeviceKind {
  String get wireName => switch (this) {
    DeviceKind.physical => 'physical',
    DeviceKind.virtual => 'virtual',
    DeviceKind.unknown => 'unknown',
  };
}

class AppOsInfo {
  const AppOsInfo({
    this.androidSdk,
    this.version,
    this.linuxDistros = const {},
    this.linuxVersionId,
    this.browser,
  });

  final int? androidSdk;
  final Version? version;
  final Set<String> linuxDistros;
  final String? linuxVersionId;
  final String? browser;

  @override
  String toString() {
    return [
      if (androidSdk != null) 'androidSdk=$androidSdk',
      if (version != null) 'version=$version',
      if (linuxDistros.isNotEmpty) 'linuxDistros=${linuxDistros.join(',')}',
      if (linuxVersionId != null) 'linuxVersionId=$linuxVersionId',
      if (browser != null) 'browser=$browser',
    ].join(',');
  }
}
