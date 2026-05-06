import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:boorusama_cli/src/builds/build_mode.dart';
import 'package:boorusama_cli/src/builds/build_plan.dart';
import 'package:boorusama_cli/src/builds/build_target.dart';
import 'package:boorusama_cli/src/io/logger.dart';
import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/package/flatpak.dart';
import 'package:boorusama_cli/src/project/env.dart';
import 'package:boorusama_cli/src/project/git.dart';
import 'package:boorusama_cli/src/project/project.dart';
import 'package:boorusama_cli/src/project/pubspec.dart';
import 'package:boorusama_cli/src/tool/tool_command.dart';
import 'package:boorusama_cli/src/tool/tool_runner.dart';
import 'package:boorusama_cli/src/tool/toolchain.dart';

void main() {
  test('builds a local Flatpak bundle from the Linux bundle', () async {
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

    final flatpakBuilderArgs = File('${root.path}/flatpak_builder_args');
    final flatpakManifest = File('${root.path}/flatpak_manifest.json');
    final flatpakBuilderScript = File('${root.path}/flatpak_builder_stub.sh');
    flatpakBuilderScript.writeAsStringSync('''
#!/usr/bin/env bash
set -euo pipefail
printf "%s" "\$*" > "${flatpakBuilderArgs.path}"
manifest="\${@: -1}"
test -f "\$manifest"
cp "\$manifest" "${flatpakManifest.path}"
''');
    final flatpakArgs = File('${root.path}/flatpak_args');
    final flatpakScript = File('${root.path}/flatpak_stub.sh');
    flatpakScript.writeAsStringSync('''
#!/usr/bin/env bash
set -euo pipefail
printf "%s" "\$*" > "${flatpakArgs.path}"
test "\$1" = "build-bundle"
test "\$4" = "$kFlatpakAppId"
touch "\$3"
''');
    await Process.run('chmod', [
      '+x',
      flatpakBuilderScript.path,
      flatpakScript.path,
    ]);

    final tools = ToolRunner(
      toolchain: Toolchain(
        flutter: const ToolCommand('flutter'),
        dart: const ToolCommand('dart'),
        git: const ToolCommand('git'),
        pod: const ToolCommand('pod'),
        zip: const ToolCommand('zip'),
        tar: const ToolCommand('tar'),
        appImageTool: const ToolCommand('appimagetool'),
        flatpak: ToolCommand(flatpakScript.path),
        flatpakBuilder: ToolCommand(flatpakBuilderScript.path),
        createDmg: const ToolCommand('create-dmg'),
      ),
      processRunner: ProcessRunner(logger: Logger()),
      root: root,
    );

    final artifact = await FlatpakPackager(
      tools,
    ).package(_project(root), _plan(root));

    expect(artifact.file.existsSync(), isTrue);
    expect(flatpakArgs.readAsStringSync(), contains(kFlatpakAppId));

    final manifest =
        jsonDecode(flatpakManifest.readAsStringSync()) as Map<String, dynamic>;
    expect(manifest['app-id'], kFlatpakAppId);
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
    target: BuildTarget.flatpak,
    buildMode: BuildMode.release,
    flutterArgs: const ['--release'],
    outputDir: Directory('${root.path}/artifacts'),
    artifactName: 'boorusama-linux-arm64.flatpak',
    targetFile: 'lib/main.dart',
  );
}
