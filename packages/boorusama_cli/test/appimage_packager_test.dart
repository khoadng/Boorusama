import 'dart:io';

import 'package:test/test.dart';

import 'package:boorusama_cli/src/builds/build_mode.dart';
import 'package:boorusama_cli/src/builds/build_plan.dart';
import 'package:boorusama_cli/src/builds/build_target.dart';
import 'package:boorusama_cli/src/io/logger.dart';
import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/package/appimage.dart';
import 'package:boorusama_cli/src/project/env.dart';
import 'package:boorusama_cli/src/project/git.dart';
import 'package:boorusama_cli/src/project/project.dart';
import 'package:boorusama_cli/src/project/pubspec.dart';
import 'package:boorusama_cli/src/tool/tool_command.dart';
import 'package:boorusama_cli/src/tool/tool_runner.dart';
import 'package:boorusama_cli/src/tool/toolchain.dart';

void main() {
  test('creates an AppDir and runs appimagetool', () async {
    final root = await Directory.systemTemp.createTemp('boorusama_cli_test_');
    addTearDown(() => root.deleteSync(recursive: true));

    final bundle = Directory('${root.path}/build/linux/arm64/release/bundle')
      ..createSync(recursive: true);
    File('${bundle.path}/boorusama').writeAsStringSync('binary');
    Directory('${bundle.path}/lib').createSync();
    Directory('${bundle.path}/data').createSync();
    final icon = File('${root.path}/assets/icon/icon-512x512.png')
      ..createSync(recursive: true);
    icon.writeAsStringSync('icon');

    final appImageToolArgs = File('${root.path}/appimagetool_args');
    final appImageToolScript = File('${root.path}/appimagetool_stub.sh');
    appImageToolScript.writeAsStringSync('''
#!/usr/bin/env bash
set -euo pipefail
printf "%s" "\$*" > "${appImageToolArgs.path}"
test -f "\$1/AppRun"
test -f "\$1/boorusama.desktop"
test -f "\$1/boorusama.png"
test -f "\$1/usr/bin/boorusama"
touch "\$2"
''');
    await Process.run('chmod', ['+x', appImageToolScript.path]);

    final tools = ToolRunner(
      toolchain: Toolchain(
        flutter: const ToolCommand('flutter'),
        dart: const ToolCommand('dart'),
        git: const ToolCommand('git'),
        pod: const ToolCommand('pod'),
        zip: const ToolCommand('zip'),
        tar: const ToolCommand('tar'),
        appImageTool: ToolCommand(appImageToolScript.path),
        createDmg: const ToolCommand('create-dmg'),
      ),
      processRunner: ProcessRunner(logger: Logger()),
      root: root,
    );

    final artifact = await AppImagePackager(
      tools,
    ).package(_project(root), _plan(root));

    expect(artifact.file.existsSync(), isTrue);
    expect(appImageToolArgs.readAsStringSync(), contains('boorusama.AppDir'));
  });
}

Project _project(Directory root) {
  return Project(
    root: root,
    pubspec: const PubspecInfo(
      name: 'boorusama',
      version: '1.0.0+1',
      versionName: '1.0.0',
      buildNumber: '1',
    ),
    env: const Env({}, includePlatform: false),
    git: const GitInfo(commit: 'commit', branch: 'branch'),
  );
}

BuildPlan _plan(Directory root) {
  return BuildPlan(
    target: BuildTarget.appimage,
    buildMode: BuildMode.release,
    flutterArgs: const ['--release'],
    outputDir: Directory('${root.path}/artifacts'),
    artifactName: 'boorusama-linux-arm64.AppImage',
    targetFile: 'lib/main.dart',
  );
}
