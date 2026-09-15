import 'package:boorusama_cli/src/tool/flutter_version_policy.dart';
import 'package:test/test.dart';

void main() {
  const expected = '3.47.2';

  test('accepts the exact official toolchain', () {
    final result = FlutterVersionPolicy.assess(
      expectedVersion: expected,
      flutterVersionOutput: 'Flutter 3.47.2 • channel stable',
      sourceBuild: false,
    );

    expect(result.compatibility, FlutterVersionCompatibility.exact);
    expect(result.actualVersion, expected);
  });

  test('accepts a patch difference only for source builds', () {
    final sourceResult = FlutterVersionPolicy.assess(
      expectedVersion: expected,
      flutterVersionOutput: 'Flutter 3.47.0 • channel stable',
      sourceBuild: true,
    );
    final officialResult = FlutterVersionPolicy.assess(
      expectedVersion: expected,
      flutterVersionOutput: 'Flutter 3.47.0 • channel stable',
      sourceBuild: false,
    );

    expect(
      sourceResult.compatibility,
      FlutterVersionCompatibility.sourcePatchDifference,
    );
    expect(
      officialResult.compatibility,
      FlutterVersionCompatibility.incompatible,
    );
  });

  test('rejects a different major or minor line', () {
    for (final version in ['3.46.9', '4.47.0']) {
      final result = FlutterVersionPolicy.assess(
        expectedVersion: expected,
        flutterVersionOutput: 'Flutter $version • channel stable',
        sourceBuild: true,
      );

      expect(
        result.compatibility,
        FlutterVersionCompatibility.incompatible,
      );
    }
  });

  test('does not treat a prerelease as the exact stable SDK', () {
    final officialResult = FlutterVersionPolicy.assess(
      expectedVersion: expected,
      flutterVersionOutput: 'Flutter 3.47.2-0.1.pre • channel beta',
      sourceBuild: false,
    );
    final sourceResult = FlutterVersionPolicy.assess(
      expectedVersion: expected,
      flutterVersionOutput: 'Flutter 3.47.2-0.1.pre • channel beta',
      sourceBuild: true,
    );

    expect(
      officialResult.compatibility,
      FlutterVersionCompatibility.incompatible,
    );
    expect(
      sourceResult.compatibility,
      FlutterVersionCompatibility.incompatible,
    );
    expect(sourceResult.actualVersion, '3.47.2-0.1.pre');
  });

  test('reports output that cannot be parsed', () {
    final result = FlutterVersionPolicy.assess(
      expectedVersion: expected,
      flutterVersionOutput: 'unknown Flutter SDK',
      sourceBuild: true,
    );

    expect(result.compatibility, FlutterVersionCompatibility.unparseable);
    expect(result.actualVersion, isNull);
  });
}
