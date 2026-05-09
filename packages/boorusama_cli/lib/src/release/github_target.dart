import '../builds/build_target.dart';
import '../io/platform.dart';

enum GithubReleaseTarget { apk, ipa, dmg, windows, linux, all }

extension GithubReleaseTargetParsing on GithubReleaseTarget {
  static GithubReleaseTarget? parse(String value) {
    for (final target in GithubReleaseTarget.values) {
      if (target.name == value) return target;
    }
    return null;
  }
}

extension GithubReleaseTargetBuild on GithubReleaseTarget {
  BuildTarget get buildTarget => switch (this) {
    GithubReleaseTarget.apk => BuildTarget.apk,
    GithubReleaseTarget.ipa => BuildTarget.ipa,
    GithubReleaseTarget.dmg => BuildTarget.dmg,
    GithubReleaseTarget.windows => BuildTarget.windows,
    GithubReleaseTarget.linux => BuildTarget.linux,
    GithubReleaseTarget.all => throw StateError(
      'all does not map to one build target',
    ),
  };

  bool supportedOn(HostPlatform host) => switch (this) {
    GithubReleaseTarget.apk =>
      host == HostPlatform.macos ||
          host == HostPlatform.linux ||
          host == HostPlatform.windows,
    GithubReleaseTarget.ipa => host == HostPlatform.macos,
    GithubReleaseTarget.dmg => host == HostPlatform.macos,
    GithubReleaseTarget.windows => host == HostPlatform.windows,
    GithubReleaseTarget.linux => host == HostPlatform.linux,
    GithubReleaseTarget.all => true,
  };
}

List<GithubReleaseTarget> githubTargetsForHost(HostPlatform host) {
  return [
    for (final target in GithubReleaseTarget.values)
      if (target != GithubReleaseTarget.all && target.supportedOn(host)) target,
  ];
}
