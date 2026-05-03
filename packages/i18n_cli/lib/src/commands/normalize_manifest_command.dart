import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../manifest.dart';
import 'base_command.dart';

final class NormalizeManifestCommand extends BaseCommand {
  @override
  String get description => 'Normalize a tolerant manifest into strict JSON.';

  @override
  String get name => 'normalize-manifest';

  @override
  String get invocation => 'booru_i18n normalize-manifest <manifest.json>';

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

    const encoder = JsonEncoder.withIndent('  ');
    stdout.writeln(encoder.convert(manifest.toJson()));
    for (final warning in manifest.warnings) {
      stderr.writeln('warning: $warning');
    }

    return 0;
  }
}
