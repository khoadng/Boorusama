import '../../builds/build_target.dart';
import '../../io/platform.dart';

enum GithubReleaseTarget {
  apk,
  ipa,
  dmg,
  windowsZip,
  linuxTarGz,
  appimage,
  host,
}

extension GithubReleaseTargetWire on GithubReleaseTarget {
  String get wireName => switch (this) {
    GithubReleaseTarget.apk => 'apk',
    GithubReleaseTarget.ipa => 'ipa',
    GithubReleaseTarget.dmg => 'dmg',
    GithubReleaseTarget.windowsZip => 'windows-zip',
    GithubReleaseTarget.linuxTarGz => 'linux-tar.gz',
    GithubReleaseTarget.appimage => 'appimage',
    GithubReleaseTarget.host => 'host',
  };
}

extension GithubReleaseTargetParsing on GithubReleaseTarget {
  static GithubReleaseTarget? parse(String value) {
    for (final target in GithubReleaseTarget.values) {
      if (target.wireName == value) return target;
    }
    return null;
  }
}

extension GithubReleaseTargetBuild on GithubReleaseTarget {
  BuildTarget get buildTarget => switch (this) {
    GithubReleaseTarget.apk => BuildTarget.apk,
    GithubReleaseTarget.ipa => BuildTarget.ipa,
    GithubReleaseTarget.dmg => BuildTarget.dmg,
    GithubReleaseTarget.windowsZip => BuildTarget.windows,
    GithubReleaseTarget.linuxTarGz => BuildTarget.linux,
    GithubReleaseTarget.appimage => BuildTarget.appimage,
    GithubReleaseTarget.host => throw StateError(
      'host does not map to one build target',
    ),
  };

  bool supportedOn(HostPlatform host) => switch (this) {
    GithubReleaseTarget.apk =>
      host == HostPlatform.macos ||
          host == HostPlatform.linux ||
          host == HostPlatform.windows,
    GithubReleaseTarget.ipa => host == HostPlatform.macos,
    GithubReleaseTarget.dmg => host == HostPlatform.macos,
    GithubReleaseTarget.windowsZip => host == HostPlatform.windows,
    GithubReleaseTarget.linuxTarGz => host == HostPlatform.linux,
    GithubReleaseTarget.appimage => host == HostPlatform.linux,
    GithubReleaseTarget.host => true,
  };
}

List<GithubReleaseTarget> githubTargetsForHost(HostPlatform host) {
  return [
    for (final target in GithubReleaseTarget.values)
      if (target != GithubReleaseTarget.host && target.supportedOn(host))
        target,
  ];
}
