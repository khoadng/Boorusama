import 'package:args/command_runner.dart';

import 'base_command.dart';

final class RemoveCommand extends BaseCommand {
  RemoveCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Locale to update.',
        valueHelp: 'locale',
      )
      ..addFlag(
        'all',
        help: 'Remove the key from every locale.',
        negatable: false,
      )
      ..addFlag(
        'dry-run',
        help: 'Validate and report changes without writing files.',
        negatable: false,
      )
      ..addFlag(
        'diff',
        help: 'Print unified diff output. Requires --dry-run.',
        negatable: false,
      );
  }

  @override
  String get description => 'Remove a translation key.';

  @override
  String get name => 'remove';

  @override
  String get invocation => 'booru_i18n remove <key> (--locale locale | --all)';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 1) {
      throw UsageException('Expected exactly one key.', usage);
    }

    final result = store.remove(
      key: parseKey(args.rest.single),
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
