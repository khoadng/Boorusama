import 'package:args/command_runner.dart';

import 'base_command.dart';

final class FormatCommand extends BaseCommand {
  FormatCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Locale to format.',
        valueHelp: 'locale',
      )
      ..addFlag(
        'all',
        help: 'Format every locale.',
        negatable: false,
      )
      ..addFlag(
        'dry-run',
        help: 'Report files that would change without writing files.',
        negatable: false,
      )
      ..addFlag(
        'diff',
        help: 'Print unified diff output. Requires --dry-run.',
        negatable: false,
      );
  }

  @override
  String get description => 'Explicitly format translation JSON files.';

  @override
  String get name => 'format';

  @override
  String get invocation => 'booru_i18n format (--locale locale | --all)';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.isNotEmpty) {
      throw UsageException('Unexpected positional arguments.', usage);
    }

    final result = store.format(
      locales: localesFromArgs(
        all: args.flag('all'),
        locale: args.option('locale'),
      ),
      dryRun: args.flag('dry-run'),
      includeDiff: includeDiffFromArgs(),
    );

    writeOperationResult(result);

    return 0;
  }
}
