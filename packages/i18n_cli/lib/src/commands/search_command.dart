import 'dart:io';

import 'package:args/command_runner.dart';

import '../json_output.dart';
import 'base_command.dart';

final class SearchCommand extends BaseCommand {
  SearchCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Only search one locale.',
        valueHelp: 'locale',
      )
      ..addOption(
        'limit',
        help: 'Maximum number of matches.',
        defaultsTo: '50',
        valueHelp: 'count',
      );
  }

  @override
  String get description => 'Search translation keys and values.';

  @override
  String get name => 'search';

  @override
  String get invocation => 'booru_i18n search <query>';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 1) {
      throw UsageException('Expected exactly one query.', usage);
    }

    final limit = int.tryParse(args.option('limit') ?? '');
    if (limit == null || limit < 1) {
      throw UsageException('--limit must be a positive integer.', usage);
    }

    final matches = store.search(
      args.rest.single,
      locale: args.option('locale'),
      limit: limit,
    );

    if (jsonOutput) {
      writeJsonLine({
        'ok': true,
        'operation': 'search',
        'count': matches.length,
        'matches': matches.map((match) => match.toJson()).toList(),
      });
    } else {
      for (final match in matches) {
        stdout.writeln('${match.locale}:${match.key} = ${match.value}');
      }
    }

    return 0;
  }
}
