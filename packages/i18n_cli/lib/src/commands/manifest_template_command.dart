import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

final class ManifestTemplateCommand extends Command<int> {
  @override
  String get description => 'Print the i18n apply manifest template.';

  @override
  String get name => 'manifest-template';

  @override
  int run() {
    const encoder = JsonEncoder.withIndent('  ');

    stdout.writeln(
      encoder.convert({
        'locale': 'en-US',
        'add': {
          'full.key.path': 'English value',
        },
        'replace': [
          {
            'file': 'relative/path.dart',
            'from': 'exact source text',
            'to': 'context.t.full.key.path',
            'count': 1,
          },
        ],
      }),
    );

    return 0;
  }
}
