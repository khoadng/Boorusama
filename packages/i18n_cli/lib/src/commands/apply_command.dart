import 'dart:io';

import 'package:args/command_runner.dart';

import '../apply_manifest.dart';
import '../manifest.dart';
import 'base_command.dart';

final class ApplyCommand extends BaseCommand {
  ApplyCommand() {
    argParser
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
  String get description => 'Apply an i18n manifest file.';

  @override
  String get name => 'apply';

  @override
  String get invocation => 'booru_i18n apply <manifest.json>';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.length != 1) {
      throw UsageException('Expected exactly one manifest file.', usage);
    }

    final manifest = I18nManifest.read(
      File(args.rest.single),
      defaultLocale: config.baseLocale,
    );
    final result = ManifestApplier(store: store).apply(
      manifest,
      dryRun: args.flag('dry-run'),
      includeDiff: includeDiffFromArgs(),
    );

    writeOperationResult(result);

    return 0;
  }
}
