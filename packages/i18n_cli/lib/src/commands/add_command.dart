import 'package:args/command_runner.dart';

import 'base_command.dart';
import 'value_args.dart';

final class AddCommand extends BaseCommand {
  AddCommand() {
    argParser
      ..addMultiOption(
        'translation',
        abbr: 't',
        help: 'Translation as locale=value. May be passed multiple times.',
        valueHelp: 'locale=value',
      )
      ..addMultiOption(
        'translation-json',
        help: 'Structured translation as locale=json. Useful for plurals.',
        valueHelp: 'locale=json',
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
  String get description => 'Add a new translation key.';

  @override
  String get name => 'add';

  @override
  String get invocation =>
      'booru_i18n add <key> --translation locale=value [...]';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 1) {
      throw UsageException('Expected exactly one key.', usage);
    }

    final result = store.add(
      key: parseKey(args.rest.single),
      translations: parseTranslations(args, usage),
      dryRun: args.flag('dry-run'),
      includeDiff: includeDiffFromArgs(),
    );

    writeOperationResult(result);

    return 0;
  }
}
