import 'dart:io';

import '../builds/build_plan.dart';
import '../io/archive.dart';
import '../io/linux_architecture.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'packager.dart';

final class LinuxPackager implements Packager {
  const LinuxPackager(this._archive);

  final Archive _archive;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    final bundle = _findBundle(project, plan);

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    await _archive.tarGzDirectory(
      source: bundle,
      output: target,
      workingDirectory: project.root,
    );
    return Artifact(type: 'Linux TAR.GZ', file: target);
  }

  Directory _findBundle(Project project, BuildPlan plan) {
    final linuxBuild = Directory('${project.root.path}/build/linux');
    final mode = plan.buildMode.name;
    final arch = currentLinuxArchitecture();

    if (arch != null) {
      final expected = Directory('${linuxBuild.path}/$arch/$mode/bundle');
      if (expected.existsSync()) return expected;
    }

    if (!linuxBuild.existsSync()) {
      throw ProcessFailure(
        'Linux build directory not found at: ${linuxBuild.path}',
      );
    }

    final candidates = linuxBuild
        .listSync()
        .whereType<Directory>()
        .map((dir) => Directory('${dir.path}/$mode/bundle'))
        .where((bundle) => bundle.existsSync())
        .toList();

    if (candidates.length == 1) return candidates.single;
    if (candidates.isEmpty) {
      final pattern = '${linuxBuild.path}/<arch>/$mode/bundle';
      throw ProcessFailure('Linux bundle not found at: $pattern');
    }

    final paths = candidates.map((candidate) => candidate.path).join(', ');
    throw ProcessFailure('Multiple Linux bundles found for $mode: $paths');
  }
}
