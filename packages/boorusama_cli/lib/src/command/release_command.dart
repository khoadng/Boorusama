import 'dart:io';

import 'package:args/command_runner.dart';

import '../builds/build_mode.dart';
import '../builds/build_options.dart';
import '../builds/build_runner.dart';
import '../builds/build_target.dart';
import '../builds/release_channel.dart';
import '../io/logger.dart';
import '../io/platform.dart';
import '../io/process_runner.dart';
import '../project/config.dart';
import '../project/project.dart';
import '../release/changelog.dart';
import '../release/github_publisher.dart';
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
    addSubcommand(ReleaseGithubBuildCommand());
    addSubcommand(ReleaseGithubPublishCommand());
  }

  @override
  String get name => 'github';

  @override
  String get description => 'Run GitHub release flows.';
}

final class ReleaseGithubBuildCommand extends Command<int> {
  ReleaseGithubBuildCommand() {
    argParser
      ..addFlag('dry-run', abbr: 'd', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('allow-dirty', negatable: false)
      ..addFlag('no-codesign', negatable: false)
      ..addOption('flavor', abbr: 'f', allowed: BoorusamaConfig.allowedFlavors)
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      );
  }

  @override
  String get name => 'build';

  @override
  String get description => 'Build GitHub release artifacts.';

  @override
  String get invocation =>
      'boorusama release github build <apk|ipa|dmg|windows-zip|linux-tar.gz|appimage|host> [options]';

  @override
  Future<int> run() async {
    final targetArg = argResults?.rest.singleOrNull;
    if (targetArg == null) {
      throw UsageException('GitHub release target is required.', usage);
    }

    final target = GithubReleaseTargetParsing.parse(targetArg);
    if (target == null) {
      throw UsageException(
        'Invalid GitHub release target: $targetArg. Valid targets: ${_targetList()}',
        usage,
      );
    }

    final dryRun = argResults?['dry-run'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final allowDirty = argResults?['allow-dirty'] as bool? ?? false;
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

      final targets = target == GithubReleaseTarget.host
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
    required bool noCodesign,
    required String? flavor,
  }) async {
    final host = currentHostPlatform();
    if (!target.supportedOn(host)) {
      throw ProcessFailure(
        '${target.wireName} release builds require a supported host. Current host is ${host.label}.',
      );
    }

    logger.info(
      'Preparing GitHub ${target.wireName} artifact for ${version.tag}',
    );

    final artifact = await BuildRunner(tools: tools, logger: logger).run(
      BuildOptions(
        target: target.buildTarget,
        flavor: _flavorFor(target, flavor),
        buildMode: BuildMode.release,
        outputDir: outputDir,
        foss: target == GithubReleaseTarget.apk,
        ci: ci,
        verbose: verbose,
        dryRun: dryRun,
        noCodesign: noCodesign,
        releaseChannel: BuildReleaseChannel.github,
        extraFlutterArgs: _extraFlutterArgsFor(target),
      ),
    );

    if (dryRun) {
      logger.info('Dry run: skipping GitHub receipt generation.');
      return;
    }

    final receipt =
        await GithubReceipt(
          outputDir: artifact.files.first.parent,
        ).write(
          target: target.wireName,
          project: project,
          version: version,
          artifact: artifact,
        );

    logger.info('Receipt: ${receipt.path}');
  }

  String? _flavorFor(GithubReleaseTarget target, String? flavor) {
    if (!target.buildTarget.requiresFlavor) return null;
    if (flavor != null) return flavor;
    return switch (target) {
      GithubReleaseTarget.apk ||
      GithubReleaseTarget.ipa ||
      GithubReleaseTarget.dmg => 'prod',
      GithubReleaseTarget.windowsZip ||
      GithubReleaseTarget.linuxTarGz ||
      GithubReleaseTarget.appimage ||
      GithubReleaseTarget.host => throw StateError(
        '${target.wireName} does not require a flavor',
      ),
    };
  }

  List<String> _extraFlutterArgsFor(GithubReleaseTarget target) {
    return switch (target) {
      GithubReleaseTarget.apk => const ['--split-per-abi'],
      _ => const [],
    };
  }

  String _targetList() {
    return GithubReleaseTarget.values
        .map((target) => target.wireName)
        .join(', ');
  }
}

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
