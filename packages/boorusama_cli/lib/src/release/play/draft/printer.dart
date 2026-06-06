import 'plan.dart';

final class PlayDraftPrinter {
  const PlayDraftPrinter();

  void printPlan(PlayDraftPlan plan, {required bool apply}) {
    print('Google Play draft release plan');
    print('');
    print('Release:');
    print('  package:  ${plan.packageName}');
    print('  track:    ${plan.track}');
    print('  version:  ${plan.version.full}');
    print('  name:     ${plan.metadata.name}');
    print('  Play max: ${_playMaxLabel(plan)}');
    print(
      '  bundle:   ${plan.willBuild ? 'build prod AAB' : plan.bundle.path}',
    );
    print(
      '  notes:    CHANGELOG.md # ${plan.version.name} (${plan.releaseNotesLanguage})',
    );
    print('  mode:     ${apply ? 'apply' : 'dry-run'}');
    print('');
    print('Release notes preview:');
    print(plan.metadata.consoleNotes);
  }

  String _playMaxLabel(PlayDraftPlan plan) {
    final versionCode = plan.playMaxVersionCode;
    if (versionCode == null) return 'none';
    final track = plan.playMaxVersionCodeTrack;
    if (track == null) return '$versionCode';
    return '$versionCode ($track)';
  }
}
