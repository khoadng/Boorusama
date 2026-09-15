enum FlutterVersionCompatibility {
  exact,
  sourcePatchDifference,
  incompatible,
  unparseable,
}

final class FlutterVersionAssessment {
  const FlutterVersionAssessment(this.compatibility, this.actualVersion);

  final FlutterVersionCompatibility compatibility;
  final String? actualVersion;
}

abstract final class FlutterVersionPolicy {
  static final _versionPattern = RegExp(
    r'^Flutter\s+(\S+)',
    multiLine: true,
  );
  static final _versionTokenPattern = RegExp(
    r'^(\d+)\.(\d+)\.(\d+)(?:[-+][0-9A-Za-z.-]+)?$',
  );

  static FlutterVersionAssessment assess({
    required String expectedVersion,
    required String flutterVersionOutput,
    required bool sourceBuild,
  }) {
    final expected = _parsePlainVersion(expectedVersion);
    final actual = _parseFlutterOutput(flutterVersionOutput);
    if (expected == null || actual == null) {
      return FlutterVersionAssessment(
        FlutterVersionCompatibility.unparseable,
        actual?.value,
      );
    }
    if (actual.value == expected.value) {
      return FlutterVersionAssessment(
        FlutterVersionCompatibility.exact,
        actual.value,
      );
    }
    if (sourceBuild &&
        actual.isStable &&
        expected.isStable &&
        actual.series == expected.series) {
      return FlutterVersionAssessment(
        FlutterVersionCompatibility.sourcePatchDifference,
        actual.value,
      );
    }
    return FlutterVersionAssessment(
      FlutterVersionCompatibility.incompatible,
      actual.value,
    );
  }

  static _FlutterVersion? _parsePlainVersion(String input) {
    final value = input.trim();
    final match = _versionTokenPattern.firstMatch(value);
    return match == null ? null : _FlutterVersion.fromMatch(match, value);
  }

  static _FlutterVersion? _parseFlutterOutput(String input) {
    final match = _versionPattern.firstMatch(input);
    return match == null ? null : _parsePlainVersion(match.group(1)!);
  }
}

final class _FlutterVersion {
  const _FlutterVersion(this.major, this.minor, this.patch, this.value);

  factory _FlutterVersion.fromMatch(RegExpMatch match, String value) =>
      _FlutterVersion(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        value,
      );

  final int major;
  final int minor;
  final int patch;
  final String value;

  String get series => '$major.$minor';
  bool get isStable => value == '$major.$minor.$patch';
}
