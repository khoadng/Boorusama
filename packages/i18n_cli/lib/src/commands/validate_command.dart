import 'dart:io';

import 'package:args/command_runner.dart';

import '../exit_codes.dart';
import '../json_output.dart';
import 'base_command.dart';

final class ValidateCommand extends BaseCommand {
  ValidateCommand() {
    argParser.addFlag(
      'run-slang',
      help: 'Reserved for future slang generation validation.',
      negatable: false,
    );
  }

  @override
  String get description => 'Validate translation files.';

  @override
  String get name => 'validate';

  @override
  String get invocation => 'booru_i18n validate';

  @override
  int run() {
    final args = argResults!;
    if (args.rest.isNotEmpty) {
      throw UsageException('Unexpected positional arguments.', usage);
    }

    final warnings = store.validate();

    if (jsonOutput) {
      writeJsonLine({
        'ok': warnings.isEmpty,
        'operation': 'validate',
        'warnings': warnings,
      });
    } else if (warnings.isEmpty) {
      stdout.writeln('Validation passed.');
    } else {
      warnings.forEach(stdout.writeln);
    }

    return warnings.isEmpty
        ? CliExitCode.success
        : CliExitCode.validationFailure;
  }
}
