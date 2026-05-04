import 'dart:io';

import 'package:args/command_runner.dart';

import '../build/build_mode.dart';
import '../build/build_options.dart';
import '../build/build_runner.dart';
import '../build/build_target.dart';
import '../io/logger.dart';
import '../io/process_runner.dart';
import '../project/config.dart';
import '../project/project.dart';
import '../tool/tool_resolver.dart';
import '../tool/tool_runner.dart';

final class BuildCommand extends Command<int> {
  BuildCommand() {
    argParser
      ..addOption('flavor', abbr: 'f', allowed: BoorusamaConfig.allowedFlavors)
      ..addFlag('foss', abbr: 's', negatable: false)
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      )
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('dry-run', abbr: 'd', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('release', negatable: false)
      ..addFlag('debug', negatable: false)
      ..addFlag('profile', negatable: false)
      ..addFlag('no-codesign', negatable: false)
      ..addFlag('fail-fast', negatable: false);
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Build Boorusama artifacts.';

  @override
  String get invocation => 'boorusama build <format> [options]';

  @override
  Future<int> run() => runWithArguments(argResults?.arguments ?? const []);

  Future<int> runWithArguments(List<String> arguments) async {
    if (arguments.contains('-h') || arguments.contains('--help')) {
      print(_usage);
      return 0;
    }

    final options = _parseOptions(arguments);
    final logger = Logger(verbose: options.verbose, ci: options.ci);
    final processRunner = ProcessRunner(
      logger: logger,
      dryRun: options.dryRun,
    );

    try {
      final root = Project.findRoot();
      final env = Project.loadEnv(root);
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
      tools.logResolvedTools();

      await BuildRunner(tools: tools, logger: logger).run(options);
      return 0;
    } on Object catch (error) {
      logger.error(error.toString());
      return 1;
    }
  }

  BuildOptions _parseOptions(List<String> arguments) {
    final parser = argParser;
    final targetIndex = arguments.indexWhere((arg) => !arg.startsWith('-'));
    if (targetIndex < 0) {
      _fail('Build format is required.');
    }

    final targetName = arguments[targetIndex];
    final target = BuildTarget.parse(targetName);
    if (target == null) {
      _fail(
        'Invalid format: $targetName. Valid formats: ${_validTargetNames()}',
      );
    }

    final boorusamaArgs = <String>[];
    final flutterArgs = <String>[];
    var passthrough = false;

    for (var i = 0; i < arguments.length; i++) {
      if (i == targetIndex) continue;

      final arg = arguments[i];
      if (passthrough) {
        flutterArgs.add(arg);
        continue;
      }

      if (arg == '--') {
        passthrough = true;
        continue;
      }

      final optionName = _canonicalOptionName(_optionName(arg));
      if (optionName == null) {
        flutterArgs.add(arg);
        continue;
      }

      if (!parser.options.containsKey(optionName)) {
        flutterArgs.add(arg);
        if (_looksLikeOptionWithValue(arguments, i)) {
          flutterArgs.add(arguments[++i]);
        }
        continue;
      }

      boorusamaArgs.add(arg);
      final option = parser.options[optionName]!;
      if (!option.isFlag && !_hasInlineValue(arg)) {
        if (i + 1 >= arguments.length) {
          _fail('Option $arg requires a value.');
        }
        boorusamaArgs.add(arguments[++i]);
      }
    }

    final results = parser.parse(boorusamaArgs);
    final flavor = _optionalString(results, 'flavor');
    if (target.requiresFlavor && flavor == null) {
      _fail(
        'Flavor is required for ${target.name}. Use --flavor <flavor>.',
      );
    }

    final buildMode = _parseBuildMode(results);
    final outputDir = _requiredString(results, 'output-dir');

    return BuildOptions(
      target: target,
      flavor: flavor,
      buildMode: buildMode,
      outputDir: Directory(outputDir),
      foss: _flag(results, 'foss'),
      verbose: _flag(results, 'verbose'),
      dryRun: _flag(results, 'dry-run'),
      ci: _flag(results, 'ci'),
      noCodesign: _flag(results, 'no-codesign'),
      failFast: _flag(results, 'fail-fast'),
      extraFlutterArgs: flutterArgs,
    );
  }

  String? _optionName(String arg) {
    if (arg == '-') return null;
    if (arg.startsWith('--')) {
      final value = arg.substring(2);
      if (value.isEmpty) return null;
      return value.split('=').first;
    }
    if (arg.startsWith('-') && arg.length > 1) {
      return arg.substring(1, 2);
    }
    return null;
  }

  String? _canonicalOptionName(String? name) {
    return switch (name) {
      null => null,
      'f' => 'flavor',
      's' => 'foss',
      'o' => 'output-dir',
      'v' => 'verbose',
      'd' => 'dry-run',
      'c' => 'ci',
      'h' => 'help',
      _ => name,
    };
  }

  bool _hasInlineValue(String arg) => arg.startsWith('--') && arg.contains('=');

  bool _looksLikeOptionWithValue(List<String> args, int index) {
    if (index + 1 >= args.length) return false;
    final next = args[index + 1];
    if (next == '--') return false;
    return !next.startsWith('-');
  }

  BuildMode _parseBuildMode(dynamic results) {
    final modes = [
      if (_flag(results, 'release')) BuildMode.release,
      if (_flag(results, 'debug')) BuildMode.debug,
      if (_flag(results, 'profile')) BuildMode.profile,
    ];

    if (modes.length > 1) {
      _fail(
        'Conflicting build modes specified. Please specify only one.',
      );
    }

    return modes.singleOrNull ?? BuildMode.release;
  }

  bool _flag(dynamic results, String name) {
    final value = results[name];
    if (value is bool) return value;
    _fail('Expected --$name to be a boolean flag.');
  }

  String _requiredString(dynamic results, String name) {
    final value = results[name];
    if (value is String && value.isNotEmpty) return value;
    _fail('Expected --$name to be a non-empty string.');
  }

  String? _optionalString(dynamic results, String name) {
    final value = results[name];
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    _fail('Expected --$name to be a string.');
  }

  String _validTargetNames() =>
      BuildTarget.values.map((e) => e.name).join(', ');

  Never _fail(String message) => throw UsageException(message, _usage);

  String get _usage =>
      '''
Usage: boorusama build <format> [options]
-h, --help           Print this usage information.
-f, --flavor         [dev, prod]
-s, --foss
-o, --output-dir     (defaults to "artifacts")
-v, --verbose
-d, --dry-run
-c, --ci
    --release
    --debug
    --profile
    --no-codesign
    --fail-fast

Unknown Flutter build options are passed through. Everything after -- is also passed through.
'''
          .trim();
}
