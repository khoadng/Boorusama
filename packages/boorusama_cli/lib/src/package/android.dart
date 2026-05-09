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
    source.copySync(target.path);
    return Artifact(
      type: plan.target == BuildTarget.apk ? 'APK' : 'AAB',
      file: target,
    );
  }
}
