import 'dart:io';

import '../builds/build_plan.dart';
import '../io/archive.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'packager.dart';

final class WebPackager implements Packager {
  const WebPackager(this._archive);

  final Archive _archive;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final webDir = Directory('${project.root.path}/build/web');
    if (!webDir.existsSync()) {
      throw ProcessFailure('Web build directory not found at: ${webDir.path}');
    }

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    await _archive.zipDirectory(
      source: webDir,
      output: target,
      workingDirectory: project.root,
    );
    return Artifact.single(type: 'Web ZIP', file: target);
  }
}
