import 'package:boorusama_cli/src/release/prepare/plan.dart';
import 'package:test/test.dart';

import '../test_support/prepare_plan.dart';

void main() {
  test('blocks versions lower than production', () {
    final plan = _plan('4.0.0');

    expect(plan.versionNamePolicy, VersionNamePolicy.blocked);
  });

  test('blocks versions equal to production', () {
    final plan = _plan('4.4.0');

    expect(plan.versionNamePolicy, VersionNamePolicy.blocked);
  });

  test('accepts the next patch version', () {
    final plan = _plan('4.4.1');

    expect(plan.versionNamePolicy, VersionNamePolicy.ok);
  });

  test('warns when requested version jumps by more than one step', () {
    final plan = _plan('4.6.0');

    expect(plan.versionNamePolicy, VersionNamePolicy.warnJump);
  });
}

ReleasePreparePlan _plan(String versionName) {
  return preparePlan(
    versionName: versionName,
    nextFullVersion: '$versionName+180',
    branch: versionName,
    tag: 'v$versionName',
    googlePlay: googlePlayPreparePlan(productionVersionName: '4.4.0'),
  );
}
