import 'dart:io';

import 'package:boorusama_cli/src/builds/foss.dart';
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
  late Directory root;
  late _RecordingProcessRunner processRunner;
  late ToolRunner tools;
  late Project project;

  setUp(() {
    root = Directory.systemTemp.createTempSync('boorusama-foss-test-');
    processRunner = _RecordingProcessRunner();
    tools = _tools(root, processRunner);
    project = Project(
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
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test(
    'resolves non-FOSS offline dependencies before running the body',
    () async {
      var bodyCalled = false;

      await FossBuild(tools: tools, logger: Logger()).guard(
        enabled: false,
        offline: true,
        project: project,
        body: (buildProject, buildTools) async {
          bodyCalled = true;
        },
      );

      expect(bodyCalled, isTrue);
      expect(processRunner.invocations, hasLength(1));
      expect(processRunner.invocations.single.args, [
        'pub',
        'get',
        '--offline',
      ]);
      expect(processRunner.invocations.single.workingDirectory.path, root.path);
    },
  );

  test('resolves FOSS metadata after rewriting the copied pubspec', () async {
    File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: boorusama
version: 1.0.0+1
dependencies:
  purchases_flutter: any
  path: any
''');
    File('${root.path}/pubspec.lock').writeAsStringSync('''
packages:
  path:
    source: hosted
  purchases_flutter:
    source: hosted
''');
    Directory('${root.path}/cached/path').createSync(recursive: true);
    final member = Directory('${root.path}/packages/member')
      ..createSync(recursive: true);
    File('${member.path}/pubspec_overrides.yaml').writeAsStringSync('''
dependency_overrides:
  path: any
''');
    final dartTool = Directory('${root.path}/.dart_tool')
      ..createSync(recursive: true);
    File('${dartTool.path}/package_config.json').writeAsStringSync('''
{
  "configVersion": 2,
  "packages": [
    {"name": "path", "rootUri": "../cached/path", "packageUri": "lib/"},
    {"name": "purchases_flutter", "rootUri": "../cached/purchases", "packageUri": "lib/"}
  ]
}
''');
    String? pubspecAtResolution;
    String? overridesAtResolution;
    bool? nestedOverridesExistAtResolution;
    processRunner.onRun = (invocation) {
      pubspecAtResolution = File(
        '${invocation.workingDirectory.path}/pubspec.yaml',
      ).readAsStringSync();
      overridesAtResolution = File(
        '${invocation.workingDirectory.path}/pubspec_overrides.yaml',
      ).readAsStringSync();
      nestedOverridesExistAtResolution = File(
        '${invocation.workingDirectory.path}/packages/member/pubspec_overrides.yaml',
      ).existsSync();
    };

    await FossBuild(tools: tools, logger: Logger()).guard(
      enabled: true,
      offline: true,
      project: project,
      body: (buildProject, buildTools) async {},
    );

    expect(processRunner.invocations, hasLength(1));
    expect(processRunner.invocations.single.args, ['pub', 'get', '--offline']);
    expect(
      processRunner.invocations.single.workingDirectory.path,
      isNot(root.path),
    );
    expect(pubspecAtResolution, isNot(contains('purchases_flutter:')));
    expect(pubspecAtResolution, contains('path: any'));
    expect(overridesAtResolution, contains('  path:'));
    expect(overridesAtResolution, isNot(contains('purchases_flutter:')));
    expect(nestedOverridesExistAtResolution, isFalse);
  });
}

ToolRunner _tools(Directory root, ProcessRunner processRunner) => ToolRunner(
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
  root: root,
);

final class _Invocation {
  const _Invocation(this.args, this.workingDirectory);

  final List<String> args;
  final Directory workingDirectory;
}

final class _RecordingProcessRunner extends ProcessRunner {
  _RecordingProcessRunner() : super(logger: Logger());

  final invocations = <_Invocation>[];
  void Function(_Invocation invocation)? onRun;

  @override
  Future<void> run(
    String executable,
    List<String> args, {
    required Directory workingDirectory,
    Map<String, String>? environment,
  }) async {
    final invocation = _Invocation(List.of(args), workingDirectory);
    invocations.add(invocation);
    onRun?.call(invocation);
  }
}
