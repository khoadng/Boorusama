final class VersionName implements Comparable<VersionName> {
  const VersionName({
    required this.major,
    required this.minor,
    required this.patch,
  });

  final int major;
  final int minor;
  final int patch;

  static VersionName? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(value);
    if (match == null) return null;

    return VersionName(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
    );
  }

  @override
  int compareTo(VersionName other) {
    final majorCompare = major.compareTo(other.major);
    if (majorCompare != 0) return majorCompare;
    final minorCompare = minor.compareTo(other.minor);
    if (minorCompare != 0) return minorCompare;
    return patch.compareTo(other.patch);
  }

  bool isMoreThanOneStepAfter(VersionName other) {
    return compareTo(other.next()) > 0;
  }

  VersionName next() {
    return VersionName(major: major, minor: minor, patch: patch + 1);
  }

  @override
  String toString() => '$major.$minor.$patch';
}
