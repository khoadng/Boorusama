import '../project/pubspec.dart';

final class ReleaseVersion {
  const ReleaseVersion({
    required this.full,
    required this.name,
    required this.buildNumber,
  });

  final String full;
  final String name;
  final String? buildNumber;

  String get tag => 'v$name';

  static ReleaseVersion fromPubspec(PubspecInfo pubspec) {
    final version = ReleaseVersion(
      full: pubspec.version,
      name: pubspec.versionName,
      buildNumber: pubspec.buildNumber,
    );
    version.validate();
    return version;
  }

  void validate() {
    final semver = RegExp(r'^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$');
    if (!semver.hasMatch(full)) {
      throw StateError('Invalid pubspec version: $full');
    }
    if (buildNumber != null && buildNumber!.isEmpty) {
      throw StateError('Invalid empty build number in pubspec version: $full');
    }
  }
}
