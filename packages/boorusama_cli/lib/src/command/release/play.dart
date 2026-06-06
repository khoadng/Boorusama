import 'dart:io';

import 'package:args/command_runner.dart';

import '../../builds/build_mode.dart';
import '../../builds/build_options.dart';
import '../../builds/build_runner.dart';
import '../../builds/build_target.dart';
import '../../builds/release_channel.dart';
import '../../io/logger.dart';
import '../../io/process_runner.dart';
import '../../project/config.dart';
import '../../project/project.dart';
import '../../release/changelog.dart';
import '../../release/git_release.dart';
import '../../release/release_version.dart';
import '../../tool/tool_resolver.dart';
import '../../tool/tool_runner.dart';
import 'play/draft.dart';

final class ReleasePlayCommand extends Command<int> {
  ReleasePlayCommand() {
    addSubcommand(ReleasePlayDraftCommand());

    argParser
      ..addFlag('dry-run', abbr: 'd', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('allow-dirty', negatable: false)
      ..addFlag('skip-build', negatable: false)
      ..addFlag('push', defaultsTo: true)
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      );
  }

  @override
  String get name => 'play';

  @override
  String get description => 'Build and tag the Play Store release.';

  @override
  String get invocation => 'boorusama release play [options]';

  @override
  Future<int> run() async {
    final dryRun = argResults?['dry-run'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final allowDirty = argResults?['allow-dirty'] as bool? ?? false;
    final skipBuild = argResults?['skip-build'] as bool? ?? false;
    final push = argResults?['push'] as bool? ?? true;
    final outputDir = Directory(
      argResults?['output-dir'] as String? ?? BoorusamaConfig.defaultOutputDir,
    );
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
      tools.logResolvedTools();

      final project = await Project.load(root: root, env: env, tools: tools);
      final version = ReleaseVersion.fromPubspec(project.pubspec);
      final notes = Changelog(File('${root.path}/CHANGELOG.md')).sectionFor(
        version.name,
      );
      final git = GitRelease(tools);

      logger.info('Preparing Play Store release ${version.tag}');
      logger.debug('Version: ${version.full}');
      logger.debug('Changelog:\n$notes');

      await git.requireCleanTree(allowDirty: allowDirty);
      await git.requireMissingTag(version.tag);

      if (!skipBuild) {
        await BuildRunner(tools: tools, logger: logger).run(
          BuildOptions(
            target: BuildTarget.aab,
            flavor: 'prod',
            buildMode: BuildMode.release,
            outputDir: outputDir,
            ci: ci,
            verbose: verbose,
            dryRun: dryRun,
            releaseChannel: BuildReleaseChannel.play,
            extraFlutterArgs: const [],
          ),
        );
      } else {
        logger.warning('Skipping prod AAB build.');
      }

      await git.createTag(version.tag, 'Release ${version.name}');
      if (push) {
        await git.pushTag(version.tag);
      } else {
        logger.warning('Created local tag only because --no-push was passed.');
      }

      logger.info('Release ${version.tag} completed.');
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
