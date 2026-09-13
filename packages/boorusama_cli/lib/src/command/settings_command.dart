import 'package:args/command_runner.dart';
import '../project/project.dart';
import '../settings/generation.dart';

final class SettingsCommand extends Command<int> {
  SettingsCommand() {
    addSubcommand(SettingsGenCommand());
  }
  @override
  String get name => 'settings';
  @override
  String get description =>
      'Generate and validate the settings catalog bindings.';
}

final class SettingsGenCommand extends Command<int> {
  SettingsGenCommand() {
    argParser
      ..addFlag(
        'check',
        negatable: false,
        help: 'Fail if generated bindings differ; write nothing.',
      )
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Validate and list changes without writing.',
      );
  }
  @override
  String get name => 'gen';
  @override
  String get description =>
      'Generate typed settings metadata from catalog/settings.yaml.';
  @override
  Future<int> run() async {
    try {
      final check = argResults!['check'] as bool;
      final dryRun = argResults!['dry-run'] as bool;
      if (check && dryRun) {
        throw UsageException('Choose --check or --dry-run.', usage);
      }
      final changed = await SettingsGeneration().run(
        Project.findRoot(),
        check: check,
        dryRun: dryRun,
      );
      print(
        check
            ? 'Settings bindings are current.'
            : '${dryRun ? 'Would generate' : 'Generated'} ${changed.length} settings files.',
      );
      return 0;
    } on Object catch (error) {
      print(error);
      return 1;
    }
  }
}
