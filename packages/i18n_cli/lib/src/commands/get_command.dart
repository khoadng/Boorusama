import 'dart:io';

import 'package:args/command_runner.dart';

import '../json_output.dart';
import 'base_command.dart';

final class GetCommand extends BaseCommand {
  GetCommand() {
    argParser.addOption(
      'locale',
      abbr: 'l',
      help: 'Locale to read. Defaults to the base locale.',
      valueHelp: 'locale',
    );
  }

  @override
  String get description => 'Read one translation key.';

  @override
  String get name => 'get';

  @override
  String get invocation => 'booru_i18n get <key> [--locale locale]';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 1) {
      throw UsageException('Expected exactly one key.', usage);
    }

    final key = parseKey(args.rest.single);
    final keyText = key.toString();
    final locale = args.option('locale') ?? config.baseLocale;
    final value = store.getValue(locale, key);

    if (jsonOutput) {
      writeJsonLine({
        'ok': true,
        'operation': 'get',
        'locale': locale,
        'key': keyText,
        'value': value,
      });
    } else {
      if (value == null) {
        stdout.writeln('$locale:$keyText <missing>');
      } else {
        stdout.writeln('$locale:$keyText = $value');
      }
    }

    return 0;
  }
}
