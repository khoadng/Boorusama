import 'dart:io';

import 'package:boorusama_cli/src/io/logger.dart';
import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/project/git.dart';
import 'package:boorusama_cli/src/tool/tool_command.dart';
import 'package:boorusama_cli/src/tool/tool_runner.dart';
import 'package:boorusama_cli/src/tool/toolchain.dart';
import 'package:test/test.dart';

void main() {
  test('explicit metadata overrides Git output', () async {
    final info = await GitInfo.read(
      _tools(_FakeProcessRunner()),
      environment: const {
        'BOORUSAMA_GIT_COMMIT': 'fixed-commit',
        'BOORUSAMA_GIT_BRANCH': 'fixed-branch',
      },
    );

    expect(info.commit, 'fixed-commit');
    expect(info.branch, 'fixed-branch');
  });

  test('falls back to Git output', () async {
    final info = await GitInfo.read(
      _tools(_FakeProcessRunner()),
      environment: const {},
    );

    expect(info.commit, 'git-commit');
    expect(info.branch, 'git-branch');
  });
}

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

final class _FakeProcessRunner extends ProcessRunner {
  _FakeProcessRunner() : super(logger: Logger());

  @override
  Future<String> output(
    String executable,
    List<String> args, {
    required Directory workingDirectory,
  }) async => args.contains('--abbrev-ref') ? 'git-branch' : 'git-commit';
}
