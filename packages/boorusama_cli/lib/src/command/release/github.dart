import 'package:args/command_runner.dart';

import 'github/build.dart';
import 'github/publish.dart';
import 'github/run.dart';

final class ReleaseGithubCommand extends Command<int> {
  ReleaseGithubCommand() {
    addSubcommand(ReleaseGithubBuildCommand());
    addSubcommand(ReleaseGithubPublishCommand());
    addSubcommand(ReleaseGithubRunCommand());
  }

  @override
  String get name => 'github';

  @override
  String get description => 'Run GitHub release flows.';
}
