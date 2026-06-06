import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../io/logger.dart';
import '../../../io/process_runner.dart';
import '../../../project/config.dart';
import '../../../project/project.dart';
import '../../../release/github/publisher.dart';
import '../../../release/github/target.dart';

final class ReleaseGithubPublishCommand extends Command<int> {
  ReleaseGithubPublishCommand() {
    argParser
      ..addFlag('dry-run', abbr: 'd', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('draft', defaultsTo: true)
      ..addFlag('prerelease', negatable: false)
      ..addFlag('verify-tag', negatable: false)
      ..addOption('repo', help: 'GitHub repository in OWNER/REPO form.')
      ..addOption(
        'tag',
        help: 'Release tag. Defaults to the tag recorded in receipts.',
      )
      ..addOption(
        'artifacts-dir',
        abbr: 'a',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
        help: 'Directory containing release artifacts and receipt JSON files.',
      )
      ..addOption(
        'notes-file',
        help: 'Markdown file to use as release notes.',
      )
      ..addOption(
        'title',
        help: 'Release title. Defaults to "Boorusama <version>".',
      )
      ..addMultiOption(
        'target',
        allowed: [
          for (final target in GithubReleaseTarget.values)
            if (target != GithubReleaseTarget.host) target.wireName,
        ],
        help: 'Required target receipt. Can be passed multiple times.',
      );
  }

  @override
  String get name => 'publish';

  @override
  String get description => 'Validate artifacts and create a GitHub release.';

  @override
  String get invocation =>
      'boorusama release github publish --repo OWNER/REPO [options]';

  @override
  Future<int> run() async {
    final repo = argResults?['repo'] as String?;
    if (repo == null || repo.isEmpty) {
      throw UsageException('--repo is required.', usage);
    }

    final dryRun = argResults?['dry-run'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final artifactsDir = Directory(
      argResults?['artifacts-dir'] as String? ??
          BoorusamaConfig.defaultOutputDir,
    );
    final targets = (argResults?['target'] as List<String>? ?? const [])
        .map((target) => GithubReleaseTargetParsing.parse(target))
        .nonNulls
        .toList();
    final logger = Logger(verbose: verbose, ci: ci);
    final processRunner = ProcessRunner(logger: logger, dryRun: dryRun);

    try {
      final root = Project.findRoot();
      await GithubPublisher(
        root: root,
        logger: logger,
        processRunner: processRunner,
      ).publish(
        options: GithubPublishOptions(
          repo: repo,
          artifactsDir: artifactsDir,
          tag: argResults?['tag'] as String?,
          title: argResults?['title'] as String?,
          notesFile: argResults?['notes-file'] == null
              ? null
              : File(argResults!['notes-file'] as String),
          draft: argResults?['draft'] as bool? ?? true,
          prerelease: argResults?['prerelease'] as bool? ?? false,
          verifyTag: argResults?['verify-tag'] as bool? ?? false,
          requiredTargets: targets.isEmpty
              ? const [
                  GithubReleaseTarget.apk,
                  GithubReleaseTarget.ipa,
                  GithubReleaseTarget.dmg,
                  GithubReleaseTarget.windowsZip,
                  GithubReleaseTarget.linuxTarGz,
                  GithubReleaseTarget.appimage,
                ]
              : targets,
        ),
      );
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
