import 'package:args/command_runner.dart';

import 'base_command.dart';
import 'value_args.dart';

final class SetCommand extends BaseCommand {
  SetCommand() {
    argParser
      ..addOption(
        'locale',
        abbr: 'l',
        help: 'Locale to update.',
        mandatory: true,
        valueHelp: 'locale',
      )
      ..addOption('value', help: 'String value to write.', valueHelp: 'text')
      ..addOption(
        'value-json',
        help: 'JSON value to write. Useful for plural objects.',
        valueHelp: 'json',
      )
      ..addFlag(
        'create',
        help: 'Create the key if it does not exist.',
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
  String get description => 'Set an existing translation value.';

  @override
  String get name => 'set';

  @override
  String get invocation => 'booru_i18n set <key> --locale locale --value text';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 1) {
      throw UsageException('Expected exactly one key.', usage);
    }

    final result = store.set(
      locale: args.option('locale')!,
      key: parseKey(args.rest.single),
      value: parseSingleValue(args, usage),
      create: args.flag('create'),
      dryRun: args.flag('dry-run'),
      includeDiff: includeDiffFromArgs(),
    );

    writeOperationResult(result);

    return 0;
  }
}
