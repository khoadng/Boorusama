import 'package:args/command_runner.dart';

import 'base_command.dart';
import 'value_args.dart';

final class AddBatchCommand extends BaseCommand {
  AddBatchCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Locale to update. Defaults to the base locale.',
        valueHelp: 'locale',
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
  String get description => 'Add multiple child keys under one parent.';

  @override
  String get name => 'add-batch';

  @override
  String get invocation => 'booru_i18n add-batch <parent-key> key=value [...]';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length < 2) {
      throw UsageException(
        'Expected a parent key and at least one key=value pair.',
        usage,
      );
    }

    final result = store.addBatch(
      parent: parseKey(args.rest.first),
      locale: args.option('locale') ?? config.baseLocale,
      values: parseKeyValues(args.rest.skip(1).toList(), usage),
      dryRun: args.flag('dry-run'),
      includeDiff: includeDiffFromArgs(),
    );

    writeOperationResult(result);

    return 0;
  }
}
