import 'dart:io';

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
import 'package:test/test.dart';

void main() {
  test('retries a Flutter build when a native-asset input changes', () async {
    final processRunner = _FailingProcessRunner(
      const ProcessFailure(
        'Flutter build failed.',
        output: 'File modified during build. Build must be rerun.',
      ),
      failureCount: 2,
    );

    await Flutter(_tools(processRunner)).build(_project, _plan);

    expect(processRunner.runCount, 3);
  });

  test('stops retrying native-asset changes after the retry limit', () async {
    final processRunner = _FailingProcessRunner(
      const ProcessFailure(
        'Flutter build failed.',
        output: 'File modified during build. Build must be rerun.',
      ),
      failureCount: 6,
    );

    await expectLater(
      Flutter(_tools(processRunner)).build(_project, _plan),
      throwsA(isA<ProcessFailure>()),
    );
    expect(processRunner.runCount, 6);
  });

  test('does not retry unrelated Flutter failures', () async {
    final processRunner = _FailingProcessRunner(
      const ProcessFailure('Flutter build failed.', output: 'compile error'),
      failureCount: 1,
    );

    await expectLater(
      Flutter(_tools(processRunner)).build(_project, _plan),
      throwsA(isA<ProcessFailure>()),
    );
    expect(processRunner.runCount, 1);
  });
}

final _project = Project(
  root: Directory.current,
  pubspec: const PubspecInfo(
    name: 'boorusama',
    version: '1.0.0',
    versionName: '1.0.0',
    buildNumber: null,
  ),
  env: const Env({}, includePlatform: false),
  git: const GitInfo(commit: 'commit', branch: 'branch'),
);

final _plan = BuildPlan(
  target: BuildTarget.linux,
  buildMode: BuildMode.release,
  flutterArgs: const ['--release'],
  outputDir: Directory.current,
  artifactName: 'boorusama.tar.gz',
  targetFile: 'lib/main.dart',
);

ToolRunner _tools(ProcessRunner processRunner) => ToolRunner(
  toolchain: const Toolchain(
    flutter: ToolCommand('flutter'),
    dart: ToolCommand('dart'),
    git: ToolCommand('git'),
    pod: ToolCommand('pod'),
    zip: ToolCommand('zip'),
    tar: ToolCommand('tar'),
    appImageTool: ToolCommand('appimagetool'),
    flatpak: ToolCommand('flatpak'),
    flatpakBuilder: ToolCommand('flatpak-builder'),
    createDmg: ToolCommand('create-dmg'),
  ),
  processRunner: processRunner,
  root: Directory.current,
);

final class _FailingProcessRunner extends ProcessRunner {
  _FailingProcessRunner(this.failure, {required this.failureCount})
    : super(logger: Logger());

  final ProcessFailure failure;
  final int failureCount;
  var runCount = 0;

  @override
  Future<void> run(
    String executable,
    List<String> args, {
    required Directory workingDirectory,
    Map<String, String>? environment,
  }) async {
    runCount++;
    if (runCount <= failureCount) throw failure;
  }
}
