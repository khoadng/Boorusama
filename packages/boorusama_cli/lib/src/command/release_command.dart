import 'package:args/command_runner.dart';

import 'release/github.dart';
import 'release/play.dart';
import 'release/prepare.dart';

final class ReleaseCommand extends Command<int> {
  ReleaseCommand() {
    addSubcommand(ReleasePrepareCommand());
    addSubcommand(ReleasePlayCommand());
    addSubcommand(ReleaseGithubCommand());
  }

  @override
  String get name => 'release';

  @override
  String get description => 'Run release flows.';
}
