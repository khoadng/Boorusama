import 'dart:io';

import '../build/build_plan.dart';
import '../io/archive.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'packager.dart';

final class WindowsPackager implements Packager {
  const WindowsPackager(this._archive);

  final Archive _archive;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final releaseDir = Directory(
      '${project.root.path}/build/windows/x64/runner/Release',
    );
    if (!releaseDir.existsSync()) {
      throw ProcessFailure(
        'Windows release directory not found at: ${releaseDir.path}',
      );
    }

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    await _archive.zipDirectory(
      source: releaseDir,
      output: target,
      workingDirectory: project.root,
    );
    return Artifact(type: 'Windows ZIP', file: target);
  }
}
