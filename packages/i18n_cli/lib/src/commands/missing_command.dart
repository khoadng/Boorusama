import 'dart:io';

import 'package:args/command_runner.dart';

import '../json_output.dart';
import 'base_command.dart';

final class MissingCommand extends BaseCommand {
  MissingCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Only check one locale.',
        valueHelp: 'locale',
      )
      ..addOption(
        'key-prefix',
        help: 'Only check keys under this prefix.',
        valueHelp: 'key',
      );
  }

  @override
  String get description => 'List translations missing from non-base locales.';

  @override
  String get name => 'missing';

  @override
  String get invocation => 'booru_i18n missing [--locale locale]';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.isNotEmpty) {
      throw UsageException('Unexpected positional arguments.', usage);
    }

    final prefix = args.option('key-prefix');
    final missing = store.missing(
      locale: args.option('locale'),
      prefix: prefix == null ? null : parseKey(prefix),
    );

    if (jsonOutput) {
      writeJsonLine({
        'ok': true,
        'operation': 'missing',
        'count': missing.length,
        'missing': missing.map((entry) => entry.toJson()).toList(),
      });
    } else if (missing.isEmpty) {
      stdout.writeln('No missing translations.');
    } else {
      for (final entry in missing) {
        stdout.writeln('${entry.locale}:${entry.key}');
      }
    }

    return missing.isEmpty ? 0 : 3;
  }
}
