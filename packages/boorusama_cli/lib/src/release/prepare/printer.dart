import 'dart:io';

import 'plan.dart';

final class ReleasePreparePrinter {
  const ReleasePreparePrinter();

  void printPlan(ReleasePreparePlan plan, {required bool apply}) {
    print('Release prepare plan');
    print('');
    print('Release:');
    print('  version: ${plan.versionName}');
    print('  branch:  ${plan.branch}');
    print('  tag:     ${plan.tag}');
    print('');
    print('Checks:');
    print(_checkLine(plan.workingTreeClean, 'working tree clean'));
    print(_checkLine(!plan.localTagExists, 'local tag available'));
    print(_checkLine(!plan.remoteTagExists, 'remote tag available'));
    print(
      _checkLine(
        plan.changelogStatus != ChangelogStatus.missing,
        'changelog section: ${plan.changelogStatus.label}',
      ),
    );
    print(_infoLine(_branchStatus(plan)));
    print('');
    print('Mode: ${apply ? 'apply' : 'dry-run'}');
  }

  void printDiffPreview(ReleasePreparePlan plan) {
    if (plan.changes.isEmpty) return;

    print('');
    print('Planned file changes:');
    for (final change in plan.changes) {
      print('diff -- ${change.path}');
      print(_red('-${change.before}'));
      print(_green('+${change.after}'));
    }
  }

  String _checkLine(bool passed, String label) {
    final status = passed ? _green('OK') : _red('FAIL');
    return '  [$status] $label';
  }

  String _infoLine(String label) => '  [INFO] $label';

  String _branchStatus(ReleasePreparePlan plan) {
    if (plan.localBranchExists) {
      return 'branch ${plan.branch} exists locally';
    }
    if (plan.remoteBranchExists) {
      return 'branch ${plan.branch} exists on origin';
    }
    return 'branch ${plan.branch} will be created';
  }

  String _red(String value) =>
      stdout.hasTerminal ? '\x1B[0;31m$value\x1B[0m' : value;

  String _green(String value) =>
      stdout.hasTerminal ? '\x1B[0;32m$value\x1B[0m' : value;
}
