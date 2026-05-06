import 'dart:io';

import 'package:test/test.dart';

import 'package:boorusama_cli/src/builds/build_mode.dart';
import 'package:boorusama_cli/src/builds/build_plan.dart';
import 'package:boorusama_cli/src/builds/build_target.dart';
import 'package:boorusama_cli/src/builds/flutter.dart';
import 'package:boorusama_cli/src/io/logger.dart';
import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/project/env.dart';
import 'package:boorusama_cli/src/project/git.dart';
import 'package:boorusama_cli/src/project/project.dart';
import 'package:boorusama_cli/src/project/pubspec.dart';
import 'package:boorusama_cli/src/tool/tool_command.dart';
import 'package:boorusama_cli/src/tool/tool_runner.dart';
import 'package:boorusama_cli/src/tool/toolchain.dart';

void main() {
  test(
    'updates CocoaPods specs and retries stale macOS pod failures',
    () async {
      final root = await Directory.systemTemp.createTemp('boorusama_cli_test_');
      addTearDown(() => root.deleteSync(recursive: true));
      Directory('${root.path}/macos').createSync();

      final attempts = File('${root.path}/flutter_attempts');
      final podCwd = File('${root.path}/pod_cwd');
      final podArgs = File('${root.path}/pod_args');
      final flutterScript = File('${root.path}/flutter_stub.sh');
      final podScript = File('${root.path}/pod_stub.sh');

      flutterScript.writeAsStringSync('''
#!/usr/bin/env bash
set -euo pipefail
attempts="${attempts.path}"
count=0
if [ -f "\$attempts" ]; then
  count=\$(cat "\$attempts")
fi
count=\$((count + 1))
echo "\$count" > "\$attempts"
if [ "\$count" -eq 1 ]; then
  echo "Error: CocoaPods's specs repository is too out-of-date to satisfy dependencies." >&2
  echo "To update the CocoaPods specs, run: pod repo update" >&2
  exit 1
fi
''');
      podScript.writeAsStringSync('''
#!/usr/bin/env bash
set -euo pipefail
printf "%s" "\$PWD" > "${podCwd.path}"
printf "%s" "\$*" > "${podArgs.path}"
''');
      await Process.run('chmod', ['+x', flutterScript.path, podScript.path]);

      final runner = ProcessRunner(logger: Logger());
      final tools = ToolRunner(
        toolchain: Toolchain(
          flutter: ToolCommand(flutterScript.path),
          dart: const ToolCommand('dart'),
          git: const ToolCommand('git'),
          pod: ToolCommand(podScript.path),
          zip: const ToolCommand('zip'),
          tar: const ToolCommand('tar'),
          appImageTool: const ToolCommand('appimagetool'),
          flatpak: const ToolCommand('flatpak'),
          flatpakBuilder: const ToolCommand('flatpak-builder'),
          createDmg: const ToolCommand('create-dmg'),
        ),
        processRunner: runner,
        root: root,
      );

      await Flutter(tools).build(_project(root), _plan(root));

      expect(attempts.readAsStringSync(), '2\n');
      expect(
        podCwd.readAsStringSync(),
        Directory('${root.path}/macos').resolveSymbolicLinksSync(),
      );
      expect(podArgs.readAsStringSync(), 'install --repo-update');
    },
  );
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
    target: BuildTarget.dmg,
    flavor: 'prod',
    buildMode: BuildMode.release,
    flutterArgs: const ['--release'],
    outputDir: root,
    artifactName: 'boorusama.dmg',
    targetFile: 'lib/main.dart',
  );
}
