import 'dart:io';

import '../builds/build_target.dart';
import '../builds/build_plan.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'packager.dart';

final class AndroidPackager implements Packager {
  const AndroidPackager();

  @override
  Future<Artifact> package(Project project, BuildPlan plan) async {
    if (plan.target == BuildTarget.apk && _isSplitPerAbi(plan)) {
      return _packageSplitApks(project, plan);
    }

    final source = switch (plan.target) {
      BuildTarget.apk => File(
        '${project.root.path}/build/app/outputs/flutter-apk/app-${plan.flavor}-${plan.buildMode.name}.apk',
      ),
      BuildTarget.aab when plan.flavor == 'dev' => File(
        '${project.root.path}/build/app/outputs/bundle/devRelease/app-dev-release.aab',
      ),
      BuildTarget.aab => File(
        '${project.root.path}/build/app/outputs/bundle/prodRelease/app-prod-release.aab',
      ),
      _ => throw const ProcessFailure('Unsupported Android target'),
    };

    if (!source.existsSync()) {
      throw ProcessFailure('Android artifact not found at: ${source.path}');
    }

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    _copyOrMoveOnNoSpace(source, target);
    return Artifact.single(
      type: plan.target == BuildTarget.apk ? 'APK' : 'AAB',
      file: target,
    );
  }

  Artifact _packageSplitApks(Project project, BuildPlan plan) {
    const abis = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];
    final targets = <File>[];

    plan.outputDir.createSync(recursive: true);
    for (final abi in abis) {
      final source = File(
        '${project.root.path}/build/app/outputs/flutter-apk/app-$abi-${plan.flavor}-${plan.buildMode.name}.apk',
      );
      if (!source.existsSync()) {
        throw ProcessFailure('Android split APK not found at: ${source.path}');
      }

      final target = File(
        '${plan.outputDir.path}/${_splitArtifactName(plan.artifactName, abi)}',
      );
      _copyOrMoveOnNoSpace(source, target);
      targets.add(target);
    }

    return Artifact(type: 'APK', files: targets);
  }

  bool _isSplitPerAbi(BuildPlan plan) =>
      plan.flutterArgs.contains('--split-per-abi');

  String _splitArtifactName(String artifactName, String abi) {
    const extension = '.apk';
    if (!artifactName.endsWith(extension)) {
      throw ProcessFailure('Unexpected APK artifact name: $artifactName');
    }
    return '${artifactName.substring(0, artifactName.length - extension.length)}-$abi$extension';
  }

  void _copyOrMoveOnNoSpace(File source, File target) {
    try {
      source.copySync(target.path);
    } on FileSystemException catch (error) {
      if (error.osError?.errorCode != 28) rethrow;
      if (target.existsSync()) target.deleteSync();
      source.renameSync(target.path);
    }
  }
}
