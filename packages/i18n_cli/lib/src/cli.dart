import 'dart:io';

import 'package:args/command_runner.dart';

import 'cli_exception.dart';
import 'commands/add_batch_command.dart';
import 'commands/add_command.dart';
import 'commands/apply_command.dart';
import 'commands/format_command.dart';
import 'commands/get_command.dart';
import 'commands/manifest_template_command.dart';
import 'commands/missing_command.dart';
import 'commands/normalize_manifest_command.dart';
import 'commands/remove_command.dart';
import 'commands/rename_command.dart';
import 'commands/search_command.dart';
import 'commands/set_command.dart';
import 'commands/tree_command.dart';
import 'commands/validate_command.dart';
import 'exit_codes.dart';

Future<void> runBooruI18n(List<String> arguments) async {
  final runner = BooruI18nCommandRunner();

  try {
    final result = await runner.run(arguments);
    exitCode = result ?? CliExitCode.success;
  } on UsageException catch (error) {
    stderr
      ..writeln(error.message)
      ..writeln()
      ..writeln(error.usage);
    exitCode = CliExitCode.usage;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = CliExitCode.malformedTranslationFile;
  } on CliException catch (error) {
    final message = error.message;
    stderr.writeln(message);
    exitCode = _exitCodeForStateError(message);
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = CliExitCode.generalFailure;
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = CliExitCode.generalFailure;
  }
}

final class BooruI18nCommandRunner extends CommandRunner<int> {
  BooruI18nCommandRunner()
    : super(
        'booru_i18n',
        'Maintain Boorusama translation JSON files safely.',
      ) {
    argParser
      ..addOption(
        'i18n-dir',
        help: 'Path to the packages/i18n directory.',
        valueHelp: 'path',
      )
      ..addFlag(
        'json',
        help: 'Print machine-readable JSON output.',
        negatable: false,
      );

    addCommand(GetCommand());
    addCommand(AddCommand());
    addCommand(AddBatchCommand());
    addCommand(ApplyCommand());
    addCommand(SetCommand());
    addCommand(RemoveCommand());
    addCommand(RenameCommand());
    addCommand(MissingCommand());
    addCommand(SearchCommand());
    addCommand(TreeCommand());
    addCommand(ValidateCommand());
    addCommand(FormatCommand());
    addCommand(ManifestTemplateCommand());
    addCommand(NormalizeManifestCommand());
  }
}

int _exitCodeForStateError(String message) {
  if (message.contains('already exists')) {
    return CliExitCode.keyAlreadyExists;
  }

  if (message.contains('not found')) {
    return CliExitCode.keyNotFound;
  }

  return CliExitCode.generalFailure;
}
