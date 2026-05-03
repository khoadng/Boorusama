import 'package:args/command_runner.dart';

import 'base_command.dart';

final class RenameCommand extends BaseCommand {
  RenameCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Locale to update.',
        valueHelp: 'locale',
      )
      ..addFlag(
        'all',
        help: 'Rename the key in every locale.',
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
  String get description => 'Rename a translation key.';

  @override
  String get name => 'rename';

  @override
  String get invocation =>
      'booru_i18n rename <old-key> <new-key> (--locale locale | --all)';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 2) {
      throw UsageException('Expected old key and new key.', usage);
    }

    final result = store.rename(
      from: parseKey(args.rest[0]),
      to: parseKey(args.rest[1]),
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
