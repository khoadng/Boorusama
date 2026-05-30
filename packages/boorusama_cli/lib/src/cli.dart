import 'dart:io';

import 'package:args/command_runner.dart';

import 'command/build_command.dart';
import 'command/doctor_command.dart';
import 'command/gen_command.dart';
import 'command/release_command.dart';

Future<void> runBoorusamaCli(List<String> args) async {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    _printHelp();
    exit(0);
  }

  if (args.firstOrNull == 'build') {
    final exitCode = await _runBuild(args.skip(1).toList());
    exit(exitCode);
  }

  final runner =
      CommandRunner<int>(
          'boorusama',
          'Boorusama development tool.',
        )
        ..addCommand(GenCommand())
        ..addCommand(I18nCommand())
        ..addCommand(BooruCommand())
        ..addCommand(DoctorCommand())
        ..addCommand(ReleaseCommand());

  final exitCode = await _run(runner, args);
  exit(exitCode);
}

Future<int> _runBuild(List<String> args) async {
  try {
    return await BuildCommand().runWithArguments(args);
  } on UsageException catch (error) {
    stderr.writeln(error);
    return 64;
  }
}

void _printHelp() {
  print('Boorusama development tool.');
  print('');
  print('Usage: boorusama <command> [arguments]');
  print('');
  print('Global options:');
  print('-h, --help    Print this usage information.');
  print('');
  print('Available commands:');
  print('  booru    Run booru client tooling.');
  print('  build    Build Boorusama artifacts.');
  print('  doctor   Check local build requirements.');
  print('  gen      Generate all repo code.');
  print('  i18n     Run i18n tooling.');
  print('  release  Run release flows.');
  print('');
  print('Run "boorusama help <command>" for more information about a command.');
}

Future<int> _run(CommandRunner<int> runner, List<String> args) async {
  try {
    return await runner.run(args) ?? 0;
  } on UsageException catch (error) {
    stderr.writeln(error);
    return 64;
  }
}
