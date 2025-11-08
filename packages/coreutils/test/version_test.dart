// Copyright (c) 2021, Matthew Barbour. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:coreutils/src/version.dart';
import 'package:test/test.dart';

void main() {
  group("equality", () {
    final cases = [
      (a: Version(0, 0, 0), b: Version(0, 0, 0), equal: true),
      (a: Version(1, 0, 0), b: Version(1, 0, 0), equal: true),
      (a: Version(0, 0, 1), b: Version(0, 0, 0), equal: false),
      (a: Version(1, 0, 0), b: Version(0, 0, 0), equal: false),
      (a: Version(5, 0, 5), b: Version(0, 0, 0), equal: false),
      (
        a: Version(1, 0, 0, build: "build"),
        b: Version(1, 0, 0),
        equal: true,
      ),
      (
        a: Version(1, 0, 0, preRelease: ["alpha"]),
        b: Version(1, 0, 0),
        equal: false,
      ),
      (
        a: Version(1, 0, 0, preRelease: ["alpha"], build: "build"),
        b: Version(1, 0, 0, preRelease: ["alpha"]),
        equal: true,
      ),
    ];

    for (final c in cases) {
      test('returns ${c.equal} for ${c.a} == ${c.b}', () {
        expect(c.a == c.b, c.equal);
      });
    }
  });

  group("comparison", () {
    final cases = [
      (a: Version(0, 0, 0), b: Version(0, 1, 0), expected: -1),
      (a: Version(0, 0, 0), b: Version(1, 0, 0), expected: -1),
      (a: Version(0, 1, 0), b: Version(0, 0, 1), expected: 1),
      (a: Version(1, 0, 0), b: Version(0, 0, 1), expected: 1),
      (a: Version(1, 0, 0), b: Version(1, 0, 0), expected: 0),
      (
        a: Version(1, 0, 0, build: "build"),
        b: Version(1, 0, 0),
        expected: 0,
      ),
      (
        a: Version(1, 0, 0, preRelease: ["alpha"]),
        b: Version(1, 0, 0),
        expected: -1,
      ),
      (
        a: Version(1, 0, 0),
        b: Version(1, 0, 0, preRelease: ["alpha"]),
        expected: 1,
      ),
      (
        a: Version(1, 0, 0, preRelease: ["alpha"]),
        b: Version(1, 0, 0, preRelease: ["alpha", "1"]),
        expected: -1,
      ),
      (
        a: Version(1, 0, 0, preRelease: ["alpha", "beta"]),
        b: Version(1, 0, 0, preRelease: ["beta"]),
        expected: -1,
      ),
      (
        a: Version(1, 0, 0, preRelease: ["beta", "2"]),
        b: Version(1, 0, 0, preRelease: ["beta", "11"]),
        expected: -1,
      ),
    ];

    for (final c in cases) {
      test('returns ${c.expected} for ${c.a}.compareTo(${c.b})', () {
        expect(c.a.compareTo(c.b), c.expected);
      });
    }
  });

  group("less than", () {
    final cases = [
      (a: Version(0, 0, 0), b: Version(0, 1, 0), result: true),
      (a: Version(0, 0, 0), b: Version(1, 0, 0), result: true),
      (a: Version(0, 1, 0), b: Version(0, 0, 1), result: false),
      (a: Version(1, 0, 0), b: Version(1, 0, 0), result: false),
      (
        a: Version(1, 0, 0, preRelease: ["alpha"]),
        b: Version(1, 0, 0),
        result: true,
      ),
    ];

    for (final c in cases) {
      test('returns ${c.result} for ${c.a} < ${c.b}', () {
        expect(c.a < c.b, c.result);
      });
    }
  });

  group("greater than", () {
    final cases = [
      (a: Version(0, 1, 0), b: Version(0, 0, 1), result: true),
      (a: Version(1, 0, 0), b: Version(0, 0, 1), result: true),
      (a: Version(0, 0, 0), b: Version(0, 1, 0), result: false),
      (a: Version(1, 0, 0), b: Version(1, 0, 0), result: false),
      (
        a: Version(1, 0, 0),
        b: Version(1, 0, 0, preRelease: ["alpha"]),
        result: true,
      ),
    ];

    for (final c in cases) {
      test('returns ${c.result} for ${c.a} > ${c.b}', () {
        expect(c.a > c.b, c.result);
      });
    }
  });

  group("less than or equal", () {
    final cases = [
      (a: Version(0, 0, 0), b: Version(0, 1, 0), result: true),
      (a: Version(1, 0, 0), b: Version(1, 0, 0), result: true),
      (a: Version(0, 1, 0), b: Version(0, 0, 1), result: false),
      (
        a: Version(1, 0, 0, build: "build"),
        b: Version(1, 0, 0),
        result: true,
      ),
    ];

    for (final c in cases) {
      test('returns ${c.result} for ${c.a} <= ${c.b}', () {
        expect(c.a <= c.b, c.result);
      });
    }
  });

  group("greater than or equal", () {
    final cases = [
      (a: Version(0, 1, 0), b: Version(0, 0, 1), result: true),
      (a: Version(1, 0, 0), b: Version(1, 0, 0), result: true),
      (a: Version(0, 0, 0), b: Version(0, 1, 0), result: false),
      (
        a: Version(1, 0, 0),
        b: Version(1, 0, 0, build: "build"),
        result: true,
      ),
    ];

    for (final c in cases) {
      test('returns ${c.result} for ${c.a} >= ${c.b}', () {
        expect(c.a >= c.b, c.result);
      });
    }
  });

  group("validation", () {
    test('throws ArgumentError for negative major', () {
      expect(() => Version(-1, 0, 0), throwsArgumentError);
    });

    test('throws ArgumentError for negative minor', () {
      expect(() => Version(1, -1, 0), throwsArgumentError);
    });

    test('throws ArgumentError for negative patch', () {
      expect(() => Version(1, 1, -1), throwsArgumentError);
    });

    test('throws ArgumentError for empty preRelease segment', () {
      expect(
        () => Version(1, 0, 0, preRelease: <String>[""]),
        throwsArgumentError,
      );
    });

    test('throws FormatException for invalid preRelease characters', () {
      expect(
        () => Version(1, 0, 0, preRelease: <String>["not^safe"]),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid build characters', () {
      expect(
        () => Version(1, 0, 0, build: "not^safe"),
        throwsFormatException,
      );
    });
  });

  group("parse", () {
    final cases = [
      (input: "0", expected: Version(0, 0, 0)),
      (input: "0.0.0", expected: Version(0, 0, 0)),
      (input: "1", expected: Version(1, 0, 0)),
      (input: "1.0", expected: Version(1, 0, 0)),
      (input: "1.2.1", expected: Version(1, 2, 1)),
      (input: "0.5.3", expected: Version(0, 5, 3)),
      (input: "1.2.3.5", expected: Version(1, 2, 3)),
      (input: "99999.55465.5456", expected: Version(99999, 55465, 5456)),
      (
        input: "1.0.0-alpha",
        expected: Version(1, 0, 0, preRelease: <String>["alpha"]),
      ),
      (input: "1.0.0+build", expected: Version(1, 0, 0, build: "build")),
      (
        input: "1.0.0-alpha+build",
        expected: Version(
          1,
          0,
          0,
          build: "build",
          preRelease: <String>["alpha"],
        ),
      ),
      (
        input: "1.0.0-alpha.beta+build",
        expected: Version(
          1,
          0,
          0,
          build: "build",
          preRelease: <String>["alpha", "beta"],
        ),
      ),
      (
        input: "1.0.0-az.AZ.12-3+az.AZ.12-3",
        expected: Version(
          1,
          0,
          0,
          build: "az.AZ.12-3",
          preRelease: <String>["az", "AZ", "12-3"],
        ),
      ),
    ];

    for (final c in cases) {
      test('parses "${c.input}" to ${c.expected}', () {
        expect(Version.parse(c.input), equals(c.expected));
      });
    }

    final invalidCases = [
      (input: "a", description: "non-numeric"),
      (input: "123,4322", description: "comma separator"),
      (input: "123a", description: "trailing letters"),
      (input: "1.0.0+not^safe", description: "invalid build characters"),
      (input: "1.0.0-not^safe", description: "invalid preRelease characters"),
    ];

    for (final c in invalidCases) {
      test('throws FormatException for ${c.description}: "${c.input}"', () {
        expect(() => Version.parse(c.input), throwsFormatException);
      });
    }
  });

  group("increment", () {
    final majorCases = [
      (input: Version(1, 0, 0), expected: Version(2, 0, 0)),
      (input: Version(1, 1, 0), expected: Version(2, 0, 0)),
      (input: Version(1, 1, 1), expected: Version(2, 0, 0)),
      (
        input: Version(1, 1, 1, preRelease: <String>["alpha"], build: "test"),
        expected: Version(2, 0, 0),
      ),
    ];

    for (final c in majorCases) {
      test('increments major from ${c.input} to ${c.expected}', () {
        expect(c.input.incrementMajor(), equals(c.expected));
      });
    }

    final minorCases = [
      (input: Version(1, 0, 0), expected: Version(1, 1, 0)),
      (input: Version(1, 1, 2), expected: Version(1, 2, 0)),
    ];

    for (final c in minorCases) {
      test('increments minor from ${c.input} to ${c.expected}', () {
        expect(c.input.incrementMinor(), equals(c.expected));
      });
    }

    final patchCases = [
      (input: Version(1, 0, 0), expected: Version(1, 0, 1)),
      (input: Version(1, 1, 2), expected: Version(1, 1, 3)),
    ];

    for (final c in patchCases) {
      test('increments patch from ${c.input} to ${c.expected}', () {
        expect(c.input.incrementPatch(), equals(c.expected));
      });
    }
  });

  group("toString", () {
    final cases = [
      (version: Version(0, 0, 0), expected: "0.0.0"),
      (version: Version(1, 0, 0), expected: "1.0.0"),
      (version: Version(1, 1, 0), expected: "1.1.0"),
      (version: Version(1, 1, 1), expected: "1.1.1"),
      (version: Version(001, 000, 0010), expected: "1.0.10"),
      (version: Version(1, 1, 1, build: "alpha"), expected: "1.1.1+alpha"),
      (
        version: Version(1, 1, 1, preRelease: <String>["alpha", "omega"]),
        expected: "1.1.1-alpha.omega",
      ),
      (
        version: Version(
          1,
          1,
          1,
          build: "alpha",
          preRelease: <String>["beta", "gamma"],
        ),
        expected: "1.1.1-beta.gamma+alpha",
      ),
    ];

    for (final c in cases) {
      test('converts ${c.version} to "${c.expected}"', () {
        expect(c.version.toString(), equals(c.expected));
      });
    }
  });

  test("validates pre-release precedence according to semver spec", () {
    final versions = <Version>[
      Version(0, 0, 0),
      Version(0, 0, 1),
      Version(0, 1, 0),
      Version.parse("1.0.0-alpha"),
      Version.parse("1.0.0-alpha.1"),
      Version.parse("1.0.0-alpha.beta"),
      Version.parse("1.0.0-beta"),
      Version.parse("1.0.0-beta.2"),
      Version.parse("1.0.0-beta.11"),
      Version.parse("1.0.0-rc.1"),
      Version.parse("1.0.0"),
      Version(5, 0, 5),
    ];

    for (int i = 0; i < versions.length; i++) {
      for (int j = 0; j < versions.length; j++) {
        final a = versions[i];
        final b = versions[j];
        if (i < j) {
          expect(a < b, isTrue, reason: "$a should be less than $b");
        } else if (i > j) {
          expect(a > b, isTrue, reason: "$a should be greater than $b");
        } else {
          expect(a == b, isTrue, reason: "$a should equal $b");
        }
      }
    }
  });

  group("hashCode", () {
    test('differs for versions with different preRelease structures', () {
      final v1 = Version(1, 0, 0, preRelease: <String>["alpha"]);
      final v2 = Version(1, 0, 0, preRelease: <String>["al", "pha"]);
      final v3 = Version(1, 0, 0);

      expect(v1.hashCode != v2.hashCode, isTrue);
      expect(v2.hashCode != v3.hashCode, isTrue);
      expect(v1.hashCode != v3.hashCode, isTrue);
    });
  });

  group("isPreRelease", () {
    final cases = [
      (version: Version(1, 0, 0, preRelease: <String>["alpha"]), result: true),
      (version: Version(1, 0, 0), result: false),
    ];

    for (final c in cases) {
      test('returns ${c.result} for ${c.version}', () {
        expect(c.version.isPreRelease, c.result);
      });
    }
  });

  group("incrementPreRelease", () {
    test('throws StateError for non-preRelease version', () {
      expect(() => Version(1, 0, 0).incrementPreRelease(), throwsStateError);
    });

    final cases = [
      (
        input: Version(1, 0, 0, preRelease: ["beta"]),
        expected: Version(1, 0, 0, preRelease: ["beta", "1"]),
      ),
      (
        input: Version(1, 0, 0, preRelease: ["alpha", "3"]),
        expected: Version(1, 0, 0, preRelease: ["alpha", "4"]),
      ),
      (
        input: Version(1, 0, 0, preRelease: ["alpha", "9", "omega"]),
        expected: Version(1, 0, 0, preRelease: ["alpha", "10", "omega"]),
      ),
    ];

    for (final c in cases) {
      test('increments from ${c.input} to ${c.expected}', () {
        expect(c.input.incrementPreRelease(), equals(c.expected));
      });
    }
  });

  group("tryParse", () {
    final stringCases = [
      (input: "1.2.3", expected: Version(1, 2, 3)),
      (input: "1.0.0", expected: Version(1, 0, 0)),
      (input: "1.0.0-alpha", expected: Version(1, 0, 0, preRelease: ["alpha"])),
      (input: "1.0.0+build", expected: Version(1, 0, 0, build: "build")),
      (
        input: "1.0.0-alpha+build",
        expected: Version(1, 0, 0, preRelease: ["alpha"], build: "build"),
      ),
      (input: "invalid", expected: null),
      (input: "", expected: null),
      (input: "not^safe", expected: null),
    ];

    for (final c in stringCases) {
      test('returns ${c.expected} for string "${c.input}"', () {
        expect(Version.tryParse(c.input), equals(c.expected));
      });
    }

    test('returns same instance for Version input', () {
      final version = Version(1, 2, 3);
      expect(identical(Version.tryParse(version), version), isTrue);
    });

    test('returns null for null input', () {
      expect(Version.tryParse(null), isNull);
    });

    final listCases = [
      (input: [1, 2, 3], expected: Version(1, 2, 3)),
      (input: [1, 0, 0], expected: Version(1, 0, 0)),
      (input: [5], expected: Version(5, 0, 0)),
      (input: [3, 2], expected: Version(3, 2, 0)),
      (input: ["1", "2", "3"], expected: Version(1, 2, 3)),
      (input: ["5"], expected: Version(5, 0, 0)),
      (input: ["3", "2"], expected: Version(3, 2, 0)),
      (input: [1, "2", 3], expected: Version(1, 2, 3)),
      (input: [], expected: null),
      (input: [1, 2, 3, 4], expected: null),
      (input: ["invalid"], expected: null),
      (input: [1, "invalid", 3], expected: null),
    ];

    for (final c in listCases) {
      test('returns ${c.expected} for list ${c.input}', () {
        expect(Version.tryParse(c.input), equals(c.expected));
      });
    }

    final recordCases = [
      (input: (1, 2, 3), expected: Version(1, 2, 3)),
      (input: (1, 0, 0), expected: Version(1, 0, 0)),
      (input: (5,), expected: Version(5, 0, 0)),
      (input: (3, 2), expected: Version(3, 2, 0)),
      (input: ("1", "2", "3"), expected: Version(1, 2, 3)),
      (input: ("5",), expected: Version(5, 0, 0)),
      (input: ("3", "2"), expected: Version(3, 2, 0)),
      (input: ("invalid", "2", "3"), expected: null),
      (input: ("1", "invalid", "3"), expected: null),
    ];

    for (final c in recordCases) {
      test('returns ${c.expected} for record ${c.input}', () {
        expect(Version.tryParse(c.input), equals(c.expected));
      });
    }

    final unsupportedTypeCases = [
      (input: 123, description: "int"),
      (input: 1.23, description: "double"),
      (input: true, description: "bool"),
    ];

    for (final c in unsupportedTypeCases) {
      test('returns null for unsupported type: ${c.description}', () {
        expect(Version.tryParse(c.input), isNull);
      });
    }

    final mapCases = [
      (
        input: {'major': 1, 'minor': 2, 'patch': 3},
        expected: Version(1, 2, 3),
      ),
      (
        input: {'major': 1},
        expected: Version(1, 0, 0),
      ),
      (
        input: {'major': 1, 'minor': 2},
        expected: Version(1, 2, 0),
      ),
      (
        input: {'major': '1', 'minor': '2', 'patch': '3'},
        expected: Version(1, 2, 3),
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'preRelease': ['alpha'],
        },
        expected: Version(1, 0, 0, preRelease: ['alpha']),
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'preRelease': ['alpha', 'beta'],
        },
        expected: Version(1, 0, 0, preRelease: ['alpha', 'beta']),
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'preRelease': 'alpha',
        },
        expected: Version(1, 0, 0, preRelease: ['alpha']),
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'preRelease': [1, 2],
        },
        expected: Version(1, 0, 0, preRelease: ['1', '2']),
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'preRelease': [true],
        },
        expected: null,
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'build': 'build123',
        },
        expected: Version(1, 0, 0, build: 'build123'),
      ),
      (
        input: {
          'major': 1,
          'minor': 0,
          'patch': 0,
          'preRelease': ['alpha'],
          'build': 'build123',
        },
        expected: Version(1, 0, 0, preRelease: ['alpha'], build: 'build123'),
      ),
      (
        input: {},
        expected: null,
      ),
      (
        input: {'minor': 2, 'patch': 3},
        expected: null,
      ),
    ];

    for (final c in mapCases) {
      test('returns ${c.expected} for map ${c.input}', () {
        expect(Version.tryParse(c.input), equals(c.expected));
      });
    }
  });
}
