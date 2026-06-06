import 'dart:io';

import 'package:args/command_runner.dart';

import '../../io/logger.dart';
import '../../io/process_runner.dart';
import '../../project/config.dart';
import '../../project/project.dart';
import '../../release/flow/options.dart';
import '../../release/flow/printer.dart';
import '../../release/flow/service.dart';
import '../../release/git/flow_step.dart';
import '../../release/git/repository.dart';
import '../../release/github/flow_step.dart';
import '../../release/play/flow_steps.dart';
import '../../release/prepare/flow_step.dart';
import '../../release/prepare/service.dart';
import '../../tool/tool_resolver.dart';
import '../../tool/tool_runner.dart';

final class ReleaseAllCommand extends Command<int> {
  ReleaseAllCommand() {
    argParser
      ..addFlag('apply', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addOption(
        'play-track',
        defaultsTo: 'internal',
        help: 'Google Play track to create the draft on.',
      )
      ..addOption(
        'github-repo',
        help:
            'GitHub repository in OWNER/REPO form. Falls back to env or GitHub origin.',
      )
      ..addOption(
        'github-workflow',
        defaultsTo: 'github-release.yml',
        help: 'GitHub Actions workflow file to validate and run.',
      )
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      );
  }

  @override
  String get name => 'all';

  @override
  String get description => 'Prepare and release all configured channels.';

  @override
  String get invocation => 'boorusama release all <version> [--apply]';

  @override
  Future<int> run() async {
    final versionName = argResults?.rest.singleOrNull;
    if (versionName == null) {
      throw UsageException('Release version is required.', usage);
    }

    final apply = argResults?['apply'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final logger = Logger(verbose: verbose, ci: ci);
    final processRunner = ProcessRunner(logger: logger);

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
      final prepareService = ReleasePrepareService(
        root: root,
        project: project,
        git: GitRelease(tools),
        onProgress: logger.info,
      );
      final flow = ReleaseFlowService(
        prepare: RealReleasePrepareStep(prepareService),
        tag: RealReleaseTagStep(
          root: root,
          env: env,
          tools: tools,
          logger: logger,
        ),
        destinations: [
          PlayReleaseDestination(
            RealReleasePlayDraftStep(
              root: root,
              env: env,
              tools: tools,
              logger: logger,
              onProgress: logger.info,
            ),
          ),
          GithubReleaseDestination(
            RealReleaseGithubStep(
              root: root,
              tools: tools,
              processRunner: processRunner,
              logger: logger,
            ),
          ),
        ],
        onProgress: logger.info,
      );
      final options = ReleaseFlowOptions(
        versionName: versionName,
        githubRepo: argResults?['github-repo'] as String?,
        githubWorkflow:
            argResults?['github-workflow'] as String? ?? 'github-release.yml',
        playDraftTrack: argResults?['play-track'] as String? ?? 'internal',
        outputDir: Directory(
          argResults?['output-dir'] as String? ??
              BoorusamaConfig.defaultOutputDir,
        ),
        releaseNotesLanguage: 'en-US',
      );
      final plan = await flow.plan(options);

      const ReleaseFlowPrinter().printPlan(plan, apply: apply);
      flow.validate(plan);

      if (!apply) {
        print('');
        print('No changes were made. Run with --apply to release.');
        return 0;
      }

      await flow.apply(plan);
      final updatedPlan = await flow.plan(options);
      const ReleaseFlowPrinter().printApplyResult(updatedPlan);
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
