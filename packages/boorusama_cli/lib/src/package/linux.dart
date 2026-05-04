import 'dart:io';

import '../build/build_plan.dart';
import '../io/archive.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'packager.dart';

final class LinuxPackager implements Packager {
  const LinuxPackager(this._archive);

  final Archive _archive;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final bundle = Directory(
      '${project.root.path}/build/linux/x64/release/bundle',
    );
    if (!bundle.existsSync()) {
      throw ProcessFailure('Linux bundle not found at: ${bundle.path}');
    }

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    await _archive.tarGzDirectory(
      source: bundle,
      output: target,
      workingDirectory: project.root,
    );
    return Artifact(type: 'Linux TAR.GZ', file: target);
  }
}
