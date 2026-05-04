import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../builds/build_mode.dart';
import '../builds/build_options.dart';
import '../builds/build_target.dart';
import '../project/config.dart';

final class BuildArgsParser {
  BuildArgsParser() {
    parser
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

  final parser = ArgParser();

  BuildOptions parse(List<String> arguments) {
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

    return BuildOptions(
      target: target,
      flavor: flavor,
      buildMode: _parseBuildMode(results),
      outputDir: Directory(_requiredString(results, 'output-dir')),
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

  BuildMode _parseBuildMode(ArgResults results) {
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

  bool _flag(ArgResults results, String name) {
    final value = results[name];
    if (value is bool) return value;
    _fail('Expected --$name to be a boolean flag.');
  }

  String _requiredString(ArgResults results, String name) {
    final value = results[name];
    if (value is String && value.isNotEmpty) return value;
    _fail('Expected --$name to be a non-empty string.');
  }

  String? _optionalString(ArgResults results, String name) {
    final value = results[name];
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    _fail('Expected --$name to be a string.');
  }

  String _validTargetNames() =>
      BuildTarget.values.map((e) => e.name).join(', ');

  Never _fail(String message) => throw UsageException(message, usage);

  String get usage =>
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
