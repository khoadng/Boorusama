import 'dart:io';

import 'package:args/command_runner.dart';

import 'base_command.dart';

final class TreeCommand extends BaseCommand {
  TreeCommand() {
    argParser.addOption(
      'depth',
      abbr: 'd',
      help: 'How many object levels to print.',
      defaultsTo: '2',
      valueHelp: 'count',
    );
  }

  @override
  String get description => 'Print the translation key tree.';

  @override
  String get name => 'tree';

  @override
  String get invocation => 'booru_i18n tree [key] [--depth count]';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length > 1) {
      throw UsageException('Expected at most one key.', usage);
    }

    final depth = int.tryParse(args.option('depth') ?? '');
    if (depth == null || depth < 0) {
      throw UsageException(
        '--depth must be zero or a positive integer.',
        usage,
      );
    }

    final tree = store.tree(
      prefix: args.rest.isEmpty ? null : parseKey(args.rest.single),
      maxDepth: depth,
    );

    stdout.write(tree);

    return 0;
  }
}
