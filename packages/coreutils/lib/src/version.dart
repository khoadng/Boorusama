// Copyright (c) 2021, Matthew Barbour. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Provides immutable storage and comparison of semantic version numbers.
class Version implements Comparable<Version> {
  static final RegExp _versionRegex = RegExp(
    r"^([\d.]+)(-([0-9A-Za-z\-.]+))?(\+([0-9A-Za-z\-.]+))?$",
  );
  static final RegExp _buildRegex = RegExp(r"^[0-9A-Za-z\-.]+$");
  static final RegExp _preReleaseRegex = RegExp(r"^[0-9A-Za-z\-]+$");

  /// The major number of the version, incremented when making breaking changes.
  final int major;

  /// The minor number of the version, incremented when adding new functionality in a backwards-compatible manner.
  final int minor;

  /// The patch number of the version, incremented when making backwards-compatible bug fixes.
  final int patch;

  /// Build information relevant to the version. Does not contribute to sorting.
  final String build;

  final List<String> _preRelease;

  /// Indicates that the version is a pre-release. Returns true if preRelease has any segments, otherwise false
  bool get isPreRelease => _preRelease.isNotEmpty;

  /// Creates a new instance of [Version].
  ///
  /// [major], [minor], and [patch] are all required, all must be greater than 0 and not null, and at least one must be greater than 0.
  /// [preRelease] is optional, but if specified must be a [List] of [String] and must not be null. Each element in the list represents one of the period-separated segments of the pre-release information, and may only contain [0-9A-Za-z-].
  /// [build] is optional, but if specified must be a [String]. must contain only [0-9A-Za-z-.], and must not be null.
  /// Throws a [FormatException] if the [String] content does not follow the character constraints defined above.
  /// Throes an [ArgumentError] if any of the other conditions are violated.
  Version(
    this.major,
    this.minor,
    this.patch, {
    List<String> preRelease = const <String>[],
    this.build = "",
  }) : _preRelease = preRelease {
    for (int i = 0; i < _preRelease.length; i++) {
      if (_preRelease[i].toString().trim().isEmpty) {
        throw ArgumentError("preRelease segments must not be empty");
      }
      // Just in case
      _preRelease[i] = _preRelease[i].toString();
      if (!_preReleaseRegex.hasMatch(_preRelease[i])) {
        throw FormatException(
          "preRelease segments must only contain [0-9A-Za-z-]",
        );
      }
    }
    if (build.isNotEmpty && !_buildRegex.hasMatch(build)) {
      throw FormatException("build must only contain [0-9A-Za-z-.]");
    }

    if (major < 0 || minor < 0 || patch < 0) {
      throw ArgumentError("Version numbers must be greater than 0");
    }
  }

  @override
  int get hashCode => toString().hashCode;

  /// Pre-release information segments.
  List<String> get preRelease => List<String>.from(_preRelease);

  /// Determines whether the left-hand [Version] represents a lower precedence than the right-hand [Version].
  bool operator <(dynamic o) => o is Version && _compare(this, o) < 0;

  /// Determines whether the left-hand [Version] represents an equal or lower precedence than the right-hand [Version].
  bool operator <=(dynamic o) => o is Version && _compare(this, o) <= 0;

  /// Determines whether the left-hand [Version] represents an equal precedence to the right-hand [Version].
  @override
  bool operator ==(Object o) => o is Version && _compare(this, o) == 0;

  /// Determines whether the left-hand [Version] represents a greater precedence than the right-hand [Version].
  bool operator >(dynamic o) => o is Version && _compare(this, o) > 0;

  /// Determines whether the left-hand [Version] represents an equal or greater precedence than the right-hand [Version].
  bool operator >=(dynamic o) => o is Version && _compare(this, o) >= 0;

  @override
  int compareTo(Version other) {
    return _compare(this, other);
  }

  /// Creates a new [Version] with the [major] version number incremented.
  ///
  /// Also resets the [minor] and [patch] numbers to 0, and clears the [build] and [preRelease] information.
  Version incrementMajor() => Version(major + 1, 0, 0);

  /// Creates a new [Version] with the [minor] version number incremented.
  ///
  /// Also resets the [patch] number to 0, and clears the [build] and [preRelease] information.
  Version incrementMinor() => Version(major, minor + 1, 0);

  /// Creates a new [Version] with the [patch] version number incremented.
  ///
  /// Also clears the [build] and [preRelease] information.
  Version incrementPatch() => Version(major, minor, patch + 1);

  /// Creates a new [Version] with the right-most numeric [preRelease] segment incremented.
  /// If no numeric segment is found, one will be added with the value "1".
  ///
  /// If this [Version] is not a pre-release version, a [StateError] will be thrown.
  Version incrementPreRelease() {
    if (!isPreRelease) {
      throw StateError(
        "Cannot increment pre-release on a non-pre-release [Version]",
      );
    }
    var newPreRelease = preRelease;

    var found = false;
    for (var i = newPreRelease.length - 1; i >= 0; i--) {
      var segment = newPreRelease[i];
      if (Version._isNumeric(segment)) {
        var intVal = int.parse(segment);
        intVal++;
        newPreRelease[i] = intVal.toString();
        found = true;
        break;
      }
    }
    if (!found) {
      newPreRelease.add("1");
    }

    return Version(
      major,
      minor,
      patch,
      preRelease: newPreRelease,
    );
  }

  /// Returns a [String] representation of the [Version].
  ///
  /// Uses the format "$major.$minor.$patch".
  /// If [preRelease] has segments available they are appended as "-segmentOne.segmentTwo", with each segment separated by a period.
  /// If [build] is specified, it is appended as "+build.info" where "build.info" is whatever value [build] is set to.
  /// If all [preRelease] and [build] are specified, then both are appended, [preRelease] first and [build] second.
  /// An example of such output would be "1.0.0-preRelease.segment+build.info".
  @override
  String toString() {
    final StringBuffer output = StringBuffer("$major.$minor.$patch");
    if (_preRelease.isNotEmpty) {
      output.write("-${_preRelease.join('.')}");
    }
    if (build.trim().isNotEmpty) {
      output.write("+${build.trim()}");
    }
    return output.toString();
  }

  /// Creates a [Version] instance from a string.
  ///
  /// The string must conform to the specification at http://semver.org/
  /// Throws [FormatException] if the string is empty or does not conform to the spec.
  static Version parse(String versionString) {
    if (versionString.trim().isEmpty) {
      throw FormatException("Cannot parse empty string into version");
    }
    if (!_versionRegex.hasMatch(versionString)) {
      throw FormatException("Not a properly formatted version string");
    }
    final Match m = _versionRegex.firstMatch(versionString)!;
    final String version = m.group(1)!;

    int? major, minor, patch;
    final List<String> parts = version.split(".");
    major = int.parse(parts[0]);
    if (parts.length > 1) {
      minor = int.parse(parts[1]);
      if (parts.length > 2) {
        patch = int.parse(parts[2]);
      }
    }

    final String preReleaseString = m.group(3) ?? "";
    List<String> preReleaseList = <String>[];
    if (preReleaseString.trim().isNotEmpty) {
      preReleaseList = preReleaseString.split(".");
    }
    final String build = m.group(5) ?? "";

    return Version(
      major,
      minor ?? 0,
      patch ?? 0,
      build: build,
      preRelease: preReleaseList,
    );
  }

  /// Attempts to create a [Version] instance from a dynamic value.
  ///
  /// Returns a [Version] if the value can be parsed as a valid version string.
  /// Returns null if the value cannot be parsed or is an unsupported type.
  ///
  /// Supports:
  /// - [String]: parsed using the semver specification
  /// - [Version]: returns the same instance
  /// - [List]: array with 1-3 elements (major, minor?, patch?) as int or String
  /// - [Record]: tuple with 1-3 elements (major, minor?, patch?) as int or String
  /// - [Map]: with keys 'major', 'minor', 'patch', 'preRelease', 'build'
  /// - null: returns null
  /// - Other types: returns null
  static Version? tryParse(dynamic value) {
    return switch (value) {
      String s => _tryParseString(s),
      Version v => v,
      Map m => _tryParseMap(m),
      List l => _tryParseList(l),
      (int, int, int) t => _tryParseRecord3(t.$1, t.$2, t.$3),
      (int, int) t => _tryParseRecord2(t.$1, t.$2),
      (int,) t => _tryParseRecord1(t.$1),
      (String, String, String) t => _tryParseRecord3(t.$1, t.$2, t.$3),
      (String, String) t => _tryParseRecord2(t.$1, t.$2),
      (String,) t => _tryParseRecord1(t.$1),
      null => null,
      _ => null,
    };
  }

  static Version? _tryParseString(String versionString) {
    try {
      return parse(versionString);
    } catch (_) {
      return null;
    }
  }

  static Version? _tryParseMap(Map map) {
    try {
      final major = _parseIntOrString(map['major']);
      if (major == null) return null;

      final minor = _parseIntOrString(map['minor']) ?? 0;
      final patch = _parseIntOrString(map['patch']) ?? 0;

      final preRelease = _parsePreRelease(map['preRelease']);
      if (preRelease == null) return null;

      final build = _parseBuild(map['build']);

      return Version(
        major,
        minor,
        patch,
        preRelease: preRelease,
        build: build,
      );
    } catch (_) {
      return null;
    }
  }

  static List<String>? _parsePreRelease(dynamic value) {
    return switch (value) {
      List<String> list => list,
      List list => _tryConvertList(list),
      String s when s.isNotEmpty => [s],
      null => <String>[],
      _ => null,
    };
  }

  static List<String>? _tryConvertList(List list) {
    if (list.any((e) => e is! String && e is! num)) {
      return null;
    }
    return list.map((e) => e.toString()).toList();
  }

  static String _parseBuild(dynamic value) {
    return switch (value) {
      String s => s,
      null => "",
      _ => "",
    };
  }

  static Version? _tryParseList(List list) {
    if (list.isEmpty || list.length > 3) return null;

    try {
      final major = _parseIntOrString(list[0]);
      if (major == null) return null;

      final minor = list.length > 1 ? _parseIntOrString(list[1]) : 0;
      if (minor == null) return null;

      final patch = list.length > 2 ? _parseIntOrString(list[2]) : 0;
      if (patch == null) return null;

      return Version(major, minor, patch);
    } catch (_) {
      return null;
    }
  }

  static Version? _tryParseRecord1(dynamic major) {
    try {
      final majorInt = _parseIntOrString(major);
      if (majorInt == null) return null;
      return Version(majorInt, 0, 0);
    } catch (_) {
      return null;
    }
  }

  static Version? _tryParseRecord2(dynamic major, dynamic minor) {
    try {
      final majorInt = _parseIntOrString(major);
      if (majorInt == null) return null;
      final minorInt = _parseIntOrString(minor);
      if (minorInt == null) return null;
      return Version(majorInt, minorInt, 0);
    } catch (_) {
      return null;
    }
  }

  static Version? _tryParseRecord3(
    dynamic major,
    dynamic minor,
    dynamic patch,
  ) {
    try {
      final majorInt = _parseIntOrString(major);
      if (majorInt == null) return null;
      final minorInt = _parseIntOrString(minor);
      if (minorInt == null) return null;
      final patchInt = _parseIntOrString(patch);
      if (patchInt == null) return null;
      return Version(majorInt, minorInt, patchInt);
    } catch (_) {
      return null;
    }
  }

  static int? _parseIntOrString(dynamic value) {
    return switch (value) {
      int i => i,
      String s => int.tryParse(s),
      _ => null,
    };
  }

  static int _compare(Version a, Version b) {
    if (a.major > b.major) return 1;
    if (a.major < b.major) return -1;

    if (a.minor > b.minor) return 1;
    if (a.minor < b.minor) return -1;

    if (a.patch > b.patch) return 1;
    if (a.patch < b.patch) return -1;

    if (a.preRelease.isEmpty) {
      if (b.preRelease.isEmpty) {
        return 0;
      } else {
        return 1;
      }
    } else if (b.preRelease.isEmpty) {
      return -1;
    } else {
      int preReleaseMax = a.preRelease.length;
      if (b.preRelease.length > a.preRelease.length) {
        preReleaseMax = b.preRelease.length;
      }

      for (int i = 0; i < preReleaseMax; i++) {
        if (b.preRelease.length <= i) {
          return 1;
        } else if (a.preRelease.length <= i) {
          return -1;
        }

        if (a.preRelease[i] == b.preRelease[i]) continue;

        final bool aNumeric = _isNumeric(a.preRelease[i]);
        final bool bNumeric = _isNumeric(b.preRelease[i]);

        if (aNumeric && bNumeric) {
          final double aNumber = double.parse(a.preRelease[i]);
          final double bNumber = double.parse(b.preRelease[i]);
          if (aNumber > bNumber) {
            return 1;
          } else {
            return -1;
          }
        } else if (bNumeric) {
          return 1;
        } else if (aNumeric) {
          return -1;
        } else {
          return a.preRelease[i].compareTo(b.preRelease[i]);
        }
      }
    }
    return 0;
  }

  static bool _isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
