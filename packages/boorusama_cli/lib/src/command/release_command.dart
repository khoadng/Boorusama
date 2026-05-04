import 'dart:io';

import 'package:args/command_runner.dart';

import '../builds/build_mode.dart';
import '../builds/build_options.dart';
import '../builds/build_runner.dart';
import '../builds/build_target.dart';
import '../io/logger.dart';
import '../io/platform.dart';
import '../io/process_runner.dart';
import '../project/config.dart';
import '../project/project.dart';
import '../release/changelog.dart';
import '../release/github_receipt.dart';
import '../release/github_target.dart';
import '../release/git_release.dart';
import '../release/release_version.dart';
import '../tool/tool_resolver.dart';
import '../tool/tool_runner.dart';

final class ReleaseCommand extends Command<int> {
  ReleaseCommand() {
    addSubcommand(ReleasePlayCommand());
    addSubcommand(ReleaseGithubCommand());
  }

  @override
  String get name => 'release';

  @override
  String get description => 'Run release flows.';
}

final class ReleaseGithubCommand extends Command<int> {
  ReleaseGithubCommand() {
    argParser
      ..addFlag('dry-run', abbr: 'd', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('allow-dirty', negatable: false)
      ..addFlag('skip-build', negatable: false)
      ..addFlag('no-codesign', negatable: false)
      ..addOption('flavor', abbr: 'f', allowed: BoorusamaConfig.allowedFlavors)
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      );
  }

  @override
  String get name => 'github';

  @override
  String get description => 'Build GitHub release artifacts.';

  @override
  String get invocation =>
      'boorusama release github <apk|ipa|dmg|windows|linux|all> [options]';

  @override
  Future<int> run() async {
    final targetArg = argResults?.rest.singleOrNull;
    if (targetArg == null) {
      throw UsageException('GitHub release target is required.', usage);
    }

    final target = GithubReleaseTargetParsing.parse(targetArg);
    if (target == null) {
      throw UsageException(
        'Invalid GitHub release target: $targetArg. Valid targets: apk, ipa, dmg, windows, linux, all',
        usage,
      );
    }

    final dryRun = argResults?['dry-run'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final allowDirty = argResults?['allow-dirty'] as bool? ?? false;
    final skipBuild = argResults?['skip-build'] as bool? ?? false;
    final noCodesign = argResults?['no-codesign'] as bool? ?? false;
    final flavor = argResults?['flavor'] as String?;
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
      logger.debug('Changelog:\n$notes');

      await GitRelease(tools).requireCleanTree(allowDirty: allowDirty);

      final targets = target == GithubReleaseTarget.all
          ? githubTargetsForHost(currentHostPlatform())
          : [target];

      if (targets.isEmpty) {
        throw ProcessFailure(
          'No GitHub release targets are supported on ${currentHostPlatform().label}.',
        );
      }

      for (final githubTarget in targets) {
        await _runTarget(
          githubTarget,
          project: project,
          version: version,
          tools: tools,
          logger: logger,
          outputDir: outputDir,
          dryRun: dryRun,
          verbose: verbose,
          ci: ci,
          skipBuild: skipBuild,
          noCodesign: noCodesign,
          flavor: flavor,
        );
      }

      logger.info('GitHub release artifact preparation completed.');
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }

  Future<void> _runTarget(
    GithubReleaseTarget target, {
    required Project project,
    required ReleaseVersion version,
    required ToolRunner tools,
    required Logger logger,
    required Directory outputDir,
    required bool dryRun,
    required bool verbose,
    required bool ci,
    required bool skipBuild,
    required bool noCodesign,
    required String? flavor,
  }) async {
    final host = currentHostPlatform();
    if (!target.supportedOn(host)) {
      throw ProcessFailure(
        '${target.name} release builds require a supported host. Current host is ${host.label}.',
      );
    }

    logger.info('Preparing GitHub ${target.name} artifact for ${version.tag}');

    final artifact = skipBuild
        ? throw const ProcessFailure(
            '--skip-build is not supported for GitHub release artifacts yet.',
          )
        : await BuildRunner(tools: tools, logger: logger).run(
            BuildOptions(
              target: target.buildTarget,
              flavor: target.buildTarget.requiresFlavor
                  ? flavor ?? _defaultFlavor(target)
                  : null,
              buildMode: BuildMode.release,
              outputDir: outputDir,
              foss: target == GithubReleaseTarget.apk,
              ci: ci,
              verbose: verbose,
              dryRun: dryRun,
              noCodesign: noCodesign,
              extraFlutterArgs: const [],
            ),
          );

    if (dryRun) {
      logger.info('Dry run: skipping GitHub receipt generation.');
      return;
    }

    final receipt =
        await GithubReceipt(
          outputDir: artifact.file.parent,
        ).write(
          target: target.name,
          project: project,
          version: version,
          artifact: artifact,
        );

    logger.info('Receipt: ${receipt.path}');
  }

  String _defaultFlavor(GithubReleaseTarget target) {
    return switch (target) {
      GithubReleaseTarget.apk || GithubReleaseTarget.dmg => 'prod',
      GithubReleaseTarget.ipa => 'dev',
      GithubReleaseTarget.windows ||
      GithubReleaseTarget.linux ||
      GithubReleaseTarget.all => throw StateError(
        '${target.name} does not require a flavor',
      ),
    };
  }
}

final class ReleasePlayCommand extends Command<int> {
  ReleasePlayCommand() {
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
