import 'package:boorusama_cli/src/release/prepare/plan.dart';
import 'package:boorusama_cli/src/release/version/prepare_plan.dart';
import 'package:test/test.dart';

void main() {
  group('ReleasePrepareVersionPlanner', () {
    test('preserves already prepared version instead of bumping again', () {
      final plan = const ReleasePrepareVersionPlanner().plan(
        currentVersionName: '4.5.0',
        currentBuildNumber: 180,
        requestedVersionName: '4.5.0',
        changelogStatus: ChangelogStatus.exactVersion,
        googlePlayMaxVersionCode: 180,
      );

      expect(plan.alreadyPrepared, isTrue);
      expect(plan.nextBuildNumber, 180);
      expect(plan.nextFullVersion, '4.5.0+180');
    });

    test('uses next Google Play code when starting a new release', () {
      final plan = const ReleasePrepareVersionPlanner().plan(
        currentVersionName: '4.4.0',
        currentBuildNumber: 177,
        requestedVersionName: '4.5.0',
        changelogStatus: ChangelogStatus.prerelease,
        googlePlayMaxVersionCode: 179,
      );

      expect(plan.alreadyPrepared, isFalse);
      expect(plan.nextBuildNumber, 180);
      expect(plan.nextFullVersion, '4.5.0+180');
    });
  });
}
