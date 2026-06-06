import 'package:args/command_runner.dart';

import '../../../io/logger.dart';
import '../../../io/process_runner.dart';
import '../../../project/project.dart';
import '../../../release/git/repository.dart';
import '../../../release/version/release_version.dart';
import '../../../tool/tool_resolver.dart';
import '../../../tool/tool_runner.dart';

final class ReleaseGithubRunCommand extends Command<int> {
  ReleaseGithubRunCommand() {
    argParser
      ..addFlag('dry-run', abbr: 'd', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('prerelease', negatable: false)
      ..addFlag('recreate-release', negatable: false)
      ..addOption('repo', help: 'GitHub repository in OWNER/REPO form.')
      ..addOption(
        'tag',
        help:
            'Release tag to build and publish. Defaults to pubspec version tag.',
      )
      ..addOption(
        'workflow',
        defaultsTo: 'github-release.yml',
        help: 'GitHub Actions workflow file to run.',
      );
  }

  @override
  String get name => 'run';

  @override
  String get description =>
      'Trigger the GitHub release workflow for a release tag.';

  @override
  String get invocation =>
      'boorusama release github run --repo OWNER/REPO [--tag vX.Y.Z]';

  @override
  Future<int> run() async {
    final repo = argResults?['repo'] as String?;
    if (repo == null || repo.isEmpty) {
      throw UsageException('--repo is required.', usage);
    }

    final dryRun = argResults?['dry-run'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final prerelease = argResults?['prerelease'] as bool? ?? false;
    final recreateRelease = argResults?['recreate-release'] as bool? ?? false;
    final workflow = argResults?['workflow'] as String? ?? 'github-release.yml';
    final logger = Logger(verbose: verbose, ci: ci);
    final processRunner = ProcessRunner(logger: logger, dryRun: dryRun);

    try {
      final root = Project.findRoot();
      final env = Project.loadEnv(root);
      final toolchain = await ToolResolver(
        root: root,
        env: env,
        processRunner: processRunner,
      ).resolve();
      final tools = ToolRunner(
        toolchain: toolchain,
        processRunner: processRunner,
        root: root,
      );
      final project = await Project.load(root: root, env: env, tools: tools);
      final tag =
          argResults?['tag'] as String? ??
          ReleaseVersion.fromPubspec(project.pubspec).tag;
      final git = GitRelease(tools);

      await git.requireLocalHeadMatchesTag(tag);
      await git.requireRemoteTag(tag);

      if (!await processRunner.exists('gh')) {
        throw const ProcessFailure(
          'GitHub CLI not found. Install gh and authenticate before running the GitHub release workflow.',
        );
      }

      logger.info('Triggering GitHub release workflow $workflow at $tag.');
      await processRunner.run(
        'gh',
        [
          'workflow',
          'run',
          workflow,
          '--repo',
          repo,
          '--ref',
          tag,
          '-f',
          'release_tag=$tag',
          '-f',
          'prerelease=$prerelease',
          '-f',
          'recreate_release=$recreateRelease',
        ],
        workingDirectory: root,
      );
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
