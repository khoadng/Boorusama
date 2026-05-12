import 'dart:io';

import '../builds/build_plan.dart';
import '../io/archive.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'linux_bundle.dart';
import 'packager.dart';

final class LinuxPackager implements Packager {
  const LinuxPackager(this._archive);

  final Archive _archive;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final bundle = findLinuxBundle(project, plan);

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    await _archive.tarGzDirectory(
      source: bundle,
      output: target,
      workingDirectory: project.root,
    );
    return Artifact.single(type: 'Linux TAR.GZ', file: target);
  }
}
