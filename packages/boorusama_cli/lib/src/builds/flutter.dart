import 'dart:io';

import '../io/process_runner.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'build_plan.dart';
import 'build_target.dart';

final class Flutter {
  const Flutter(this._tools);

  final ToolRunner _tools;

  Future<void> build(Project project, BuildPlan plan) async {
    final args = [
      'build',
      plan.target.flutterTarget,
      ...plan.flutterArgs,
    ];

    try {
      await _tools.flutter(args);
    } on ProcessFailure catch (error) {
      if (!_shouldRetryWithUpdatedPods(plan.target, error)) rethrow;
      await _updatePods(project, plan.target);
      await _tools.flutter(args);
    }
  }

  bool _shouldRetryWithUpdatedPods(BuildTarget target, ProcessFailure error) {
    if (target != BuildTarget.dmg && target != BuildTarget.ipa) return false;

    final output = error.output;
    return output.contains(
          "CocoaPods's specs repository is too out-of-date",
        ) ||
        output.contains('pod install --repo-update') ||
        output.contains('pod repo update');
  }

  Future<void> _updatePods(Project project, BuildTarget target) async {
    final platformDir = Directory(
      '${project.root.path}/${_podDirectory(target)}',
    );
    if (!platformDir.existsSync()) {
      throw ProcessFailure('${platformDir.path} does not exist.');
    }

    _tools.processRunner.logger.info(
      'CocoaPods specs are stale. Running pod install --repo-update and retrying ${target.flutterTarget} build...',
    );
    await _tools.pod(['install', '--repo-update'], cwd: platformDir);
  }

  String _podDirectory(BuildTarget target) => switch (target) {
    BuildTarget.dmg => 'macos',
    BuildTarget.ipa => 'ios',
    _ => throw ArgumentError('Target ${target.name} does not use CocoaPods.'),
  };
}
