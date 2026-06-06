import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/prepare/service.dart';
import 'package:test/test.dart';

import '../test_support/prepare_plan.dart';

void main() {
  for (final version in ['4', '4.5', '4.5.0-beta', '4.5.0+180', 'next']) {
    test('rejects invalid release version "$version"', () {
      final plan = preparePlan(
        versionName: version,
        nextFullVersion: '$version+180',
        branch: version,
        tag: 'v$version',
      );

      expect(
        () => ReleasePrepareService.validatePlan(plan),
        throwsA(
          isA<ProcessFailure>().having(
            (error) => error.message,
            'message',
            'Invalid release version: $version. Expected X.Y.Z.',
          ),
        ),
      );
    });
  }

  test('accepts X.Y.Z release version input', () {
    final plan = preparePlan(
      versionName: '4.5.0',
      nextFullVersion: '4.5.0+180',
      branch: '4.5.0',
      tag: 'v4.5.0',
    );

    expect(() => ReleasePrepareService.validatePlan(plan), returnsNormally);
  });

  test('accepts existing tag and GitHub release for already prepared plan', () {
    final plan = preparePlan(
      versionName: '4.5.0',
      nextFullVersion: '4.5.0+180',
      branch: '4.5.0',
      tag: 'v4.5.0',
      alreadyPrepared: true,
      localTagExists: true,
      remoteTagExists: true,
      github: githubPreparePlan(releaseExists: true),
    );

    expect(() => ReleasePrepareService.validatePlan(plan), returnsNormally);
  });
}
