import 'dart:io';

import 'package:args/command_runner.dart';

import '../builds/build_requirements.dart';
import '../builds/build_target.dart';
import '../builds/foss_backups.dart';
import '../builds/output_dir.dart';
import '../io/logger.dart';
import '../io/platform.dart';
import '../io/process_runner.dart';
import '../project/config.dart';
import '../project/env.dart';
import '../project/project.dart';
import '../tool/tool_command.dart';
import '../tool/tool_resolver.dart';
import '../tool/tool_runner.dart';

final class DoctorCommand extends Command<int> {
  DoctorCommand() {
    argParser
      ..addOption('flavor', abbr: 'f', allowed: BoorusamaConfig.allowedFlavors)
      ..addFlag('foss', abbr: 's', negatable: false)
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      )
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false);
  }

  @override
  String get name => 'doctor';

  @override
  String get description => 'Check local build requirements.';

  @override
  String get invocation => 'boorusama doctor [format] [options]';

  @override
  Future<int> run() async {
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final logger = Logger(verbose: verbose, ci: ci);
    final target = _target();
    final flavor = argResults?['flavor'] as String?;
    final foss = argResults?['foss'] as bool? ?? false;
    final outputDir = Directory(
      argResults?['output-dir'] as String? ?? BoorusamaConfig.defaultOutputDir,
    );
    final results = <_CheckResult>[];

    try {
      final root = Project.findRoot();
      final env = Project.loadEnv(root);
      final processRunner = ProcessRunner(logger: logger);
      final toolchain = await ToolResolver(
        root: root,
        env: env,
        processRunner: processRunner,
      ).resolve();
      final tools = ToolRunner(
        toolchain: toolchain,
        processRunner: processRunner,
        root: root,
      );

      results
        ..add(_CheckResult.ok('Project root', root.path))
        ..add(
          _CheckResult.ok(
            'FVM marker',
            File('${root.path}/.fvmrc').existsSync() ? '.fvmrc' : 'not present',
          ),
        )
        ..add(
          await _toolVersion(
            'Flutter',
            () => tools.flutterOutput(['--version']),
          ),
        )
        ..add(await _toolVersion('Dart', () => tools.dartOutput(['--version'])))
        ..add(await _toolExists('Git', tools, tools.toolchain.git))
        ..add(_checkOutputDir(OutputDir.resolve(root, outputDir)))
        ..addAll(await _targetChecks(target, flavor, foss, env, tools))
        ..add(_checkFossBackups(root));
    } on Object catch (error) {
      results.add(_CheckResult.error('Doctor setup', error.toString()));
    }

    _printResults(results);
    return results.any((r) => r.severity == _Severity.error) ? 1 : 0;
  }

  BuildTarget? _target() {
    final rest = argResults?.rest ?? const <String>[];
    if (rest.isEmpty) return null;
    final target = BuildTarget.parse(rest.first);
    if (target == null) {
      throw UsageException(
        'Invalid format: ${rest.first}. Valid formats: ${BuildTarget.values.map((e) => e.name).join(', ')}',
        usage,
      );
    }
    return target;
  }

  Future<List<_CheckResult>> _targetChecks(
    BuildTarget? target,
    String? flavor,
    bool foss,
    Env env,
    ToolRunner tools,
  ) async {
    if (target == null) return const [];

    final checks = <_CheckResult>[];
    final requiredHost = BuildRequirements.requiredHost(target);

    if (requiredHost != null) {
      final current = currentHostPlatform();
      checks.add(
        current == requiredHost
            ? _CheckResult.ok('Host platform', current.label)
            : _CheckResult.error(
                'Host platform',
                '${target.name} requires ${requiredHost.label}, current is ${current.label}',
              ),
      );
    }

    if (target.requiresFlavor && flavor == null) {
      checks.add(
        _CheckResult.error(
          'Flavor',
          '${target.name} requires --flavor dev|prod',
        ),
      );
    }

    for (final tool in BuildRequirements.requiredTools(
      target,
      tools.toolchain,
    )) {
      final hint = tool == tools.toolchain.createDmg
          ? 'brew install create-dmg'
          : tool == tools.toolchain.pod
          ? 'brew install cocoapods'
          : tool == tools.toolchain.appImageTool
          ? 'optional; appimage builds download it when missing'
          : tool == tools.toolchain.flatpak ||
                tool == tools.toolchain.flatpakBuilder
          ? 'install with your distro package manager'
          : null;
      checks.add(await _toolExists(tool.displayName, tools, tool, hint: hint));
    }

    for (final requirement in BuildRequirements.requiredEnv(
      target: target,
      flavor: flavor,
      foss: foss,
      noCodesign: false,
    )) {
      checks.add(_envKey(env, requirement.key));
    }

    return checks;
  }

  Future<_CheckResult> _toolVersion(
    String name,
    Future<String> Function() getVersion,
  ) async {
    final output = await getVersion();
    if (output == 'unknown' || output.isEmpty) {
      return _CheckResult.error(name, 'not available');
    }
    return _CheckResult.ok(name, output.split('\n').first);
  }

  Future<_CheckResult> _toolExists(
    String name,
    ToolRunner tools,
    ToolCommand command, {
    String? hint,
  }) async {
    final exists = await tools.exists(command);
    if (exists) return _CheckResult.ok(name, command.displayName);
    return _CheckResult.error(
      name,
      hint == null ? 'missing' : 'missing ($hint)',
    );
  }

  _CheckResult _checkOutputDir(Directory outputDir) {
    try {
      if (!outputDir.existsSync()) outputDir.createSync(recursive: true);
      final probe = File('${outputDir.path}/.boorusama_cli_doctor_write_test');
      probe.writeAsStringSync('ok');
      probe.deleteSync();
      return _CheckResult.ok('Output directory', outputDir.path);
    } on Object catch (error) {
      return _CheckResult.error(
        'Output directory',
        '${outputDir.path}: $error',
      );
    }
  }

  _CheckResult _envKey(Env env, String key) {
    final value = env[key];
    if (value != null && value.isNotEmpty) return _CheckResult.ok(key, 'set');
    return _CheckResult.error(key, 'missing in .env or environment');
  }

  _CheckResult _checkFossBackups(Directory root) {
    final backups = FossBackups.find(
      root,
    ).map(FossBackups.displayName).toList();

    if (backups.isEmpty) return const _CheckResult.ok('FOSS backups', 'none');
    return _CheckResult.warning('FOSS backups', backups.join(', '));
  }

  void _printResults(List<_CheckResult> results) {
    for (final result in results) {
      final marker = switch (result.severity) {
        _Severity.ok => 'ok',
        _Severity.warning => 'warn',
        _Severity.error => 'error',
      };
      print(
        '${marker.padRight(5)} ${result.name.padRight(24)} ${result.message}',
      );
    }
  }
}

enum _Severity { ok, warning, error }

final class _CheckResult {
  const _CheckResult(this.severity, this.name, this.message);
  const _CheckResult.ok(String name, String message)
    : this(_Severity.ok, name, message);
  const _CheckResult.warning(String name, String message)
    : this(_Severity.warning, name, message);
  const _CheckResult.error(String name, String message)
    : this(_Severity.error, name, message);

  final _Severity severity;
  final String name;
  final String message;
}
