import 'dart:io';

import '../builds/build_plan.dart';
import '../builds/build_target.dart';
import '../io/process_runner.dart';
import '../tool/tool_runner.dart';
import '../project/project.dart';
import 'artifact.dart';
import 'packager.dart';

final class ApplePackager implements Packager {
  const ApplePackager(this._tools);

  final ToolRunner _tools;

  @override
  Future<Artifact> package(Project project, BuildPlan plan) {
    return switch (plan.target) {
      BuildTarget.ipa => _packageIpa(project, plan),
      BuildTarget.dmg => _packageDmg(project, plan),
      _ => throw const ProcessFailure('Unsupported Apple target'),
    };
  }

  Future<Artifact> _packageIpa(Project project, BuildPlan plan) async {
    final appPath = plan.flavor == 'dev'
        ? '${project.root.path}/build/ios/Release-dev-iphoneos/Boorusama-DEV.app'
        : '${project.root.path}/build/ios/Release-prod-iphoneos/Boorusama.app';
    final app = Directory(appPath);
    if (!app.existsSync()) {
      throw ProcessFailure('iOS app not found at: $appPath');
    }

    final payload = Directory('${project.root.path}/build/Payload');
    if (payload.existsSync()) payload.deleteSync(recursive: true);
    payload.createSync(recursive: true);

    await _tools.processRunner.run('cp', [
      '-R',
      app.path,
      payload.path,
    ], workingDirectory: project.root);

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    if (target.existsSync()) target.deleteSync();
    await _tools.zip([
      '-rq',
      target.absolute.path,
      'Payload',
    ], cwd: Directory('${project.root.path}/build'));
    payload.deleteSync(recursive: true);
    return Artifact(type: 'IPA', file: target);
  }

  Future<Artifact> _packageDmg(Project project, BuildPlan plan) async {
    final app = Directory(
      '${project.root.path}/build/macos/Build/Products/Release/boorusama.app',
    );
    if (!app.existsSync()) {
      throw ProcessFailure('macOS app not found at: ${app.path}');
    }

    final tempApp = Directory('${project.root.path}/build/boorusama.app');
    if (tempApp.existsSync()) tempApp.deleteSync(recursive: true);
    await _tools.processRunner.run('cp', [
      '-R',
      app.path,
      tempApp.path,
    ], workingDirectory: project.root);

    final buildDmg = File('${project.root.path}/build/${plan.artifactName}');
    if (buildDmg.existsSync()) buildDmg.deleteSync();
    await _tools.createDmg([
      '--hdiutil-quiet',
      buildDmg.path,
      tempApp.path,
    ], cwd: project.root);
    tempApp.deleteSync(recursive: true);

    plan.outputDir.createSync(recursive: true);
    final target = File('${plan.outputDir.path}/${plan.artifactName}');
    buildDmg.copySync(target.path);
    return Artifact(type: 'DMG', file: target);
  }
}
