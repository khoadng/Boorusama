import 'dart:io';

import 'package:args/command_runner.dart';

import '../config.dart';
import '../json_output.dart';
import '../key_path.dart';
import '../operation_result.dart';
import '../translation_store.dart';

abstract class BaseCommand extends Command<int> {
  bool get jsonOutput => globalResults?.flag('json') ?? false;

  I18nCliConfig get config => I18nCliConfig.load(
    workingDirectory: Directory.current.path,
    i18nDirectory: globalResults?['i18n-dir'] as String?,
  );

  TranslationStore get store => TranslationStore(config);

  KeyPath parseKey(String source) {
    try {
      return KeyPath.parse(source);
    } on FormatException catch (error) {
      throw UsageException(error.message, usage);
    }
  }

  void writeOperationResult(OperationResult result) {
    if (jsonOutput) {
      writeJsonLine(result.toJson());

      return;
    }

    stdout.writeln('${result.operation}: ok');
    if (result.key != null) {
      stdout.writeln('key: ${result.key}');
    }
    if (result.changedFiles.isNotEmpty) {
      stdout.writeln('changed:');
      for (final file in result.changedFiles) {
        stdout.writeln('  $file');
      }
    }
    if (result.addedKeys.isNotEmpty) {
      stdout.writeln('new keys:');
      for (final key in result.addedKeys) {
        stdout.writeln('  $key');
      }
    }
    if (result.existingKeys.isNotEmpty) {
      stdout.writeln('already exists:');
      for (final existing in result.existingKeys) {
        stdout.writeln('  ${existing.key} = ${existing.value}');
      }
    }
    if (result.sameValueMatches.isNotEmpty) {
      stdout.writeln('same value elsewhere:');
      for (final match in result.sameValueMatches) {
        stdout.writeln(
          '  ${match.proposedKey}: ${match.existingKey} = ${match.value}',
        );
      }
    }
    if (result.replacements.isNotEmpty) {
      stdout.writeln('replacements:');
      final countsByFile = <String, int>{};
      for (final replacement in result.replacements) {
        countsByFile.update(
          replacement.file,
          (count) => count + replacement.count,
          ifAbsent: () => replacement.count,
        );
      }
      for (final entry in countsByFile.entries) {
        stdout.writeln('  ${entry.key}: ${entry.value} replacement(s)');
      }
    }
    if (result.missingLocales.isNotEmpty) {
      stdout.writeln('missing locales: ${result.missingLocales.join(', ')}');
    }
    for (final warning in result.warnings) {
      stderr.writeln('warning: $warning');
    }
    for (final diff in result.diffs) {
      stdout.write(diff.diff);
    }
  }

  bool includeDiffFromArgs() {
    final args = argResults!;
    final includeDiff = args.flag('diff');

    if (includeDiff && !args.flag('dry-run')) {
      throw UsageException('--diff requires --dry-run.', usage);
    }

    return includeDiff;
  }

  List<String> localesFromArgs({
    required bool all,
    required String? locale,
  }) {
    if (all && locale != null) {
      throw UsageException('Use either --all or --locale, not both.', usage);
    }

    if (all) return store.discoverLocales();
    if (locale != null) return [locale];

    throw UsageException('Specify --locale or --all.', usage);
  }
}
