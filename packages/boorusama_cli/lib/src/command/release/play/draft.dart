import 'dart:io';

import 'package:args/command_runner.dart';

import '../../../io/logger.dart';
import '../../../io/process_runner.dart';
import '../../../project/config.dart';
import '../../../project/project.dart';
import '../../../release/play/draft/printer.dart';
import '../../../release/play/draft/service.dart';
import '../../../tool/tool_resolver.dart';
import '../../../tool/tool_runner.dart';

final class ReleasePlayDraftCommand extends Command<int> {
  ReleasePlayDraftCommand() {
    argParser
      ..addFlag('apply', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false)
      ..addFlag('allow-dirty', negatable: false)
      ..addOption(
        'track',
        defaultsTo: 'internal',
        help: 'Google Play track to create the draft on.',
      )
      ..addOption(
        'bundle',
        help: 'Existing AAB to upload. If omitted, builds a prod AAB first.',
      )
      ..addOption(
        'output-dir',
        abbr: 'o',
        defaultsTo: BoorusamaConfig.defaultOutputDir,
      )
      ..addOption(
        'release-notes-language',
        defaultsTo: 'en-US',
        help: 'Language for the uploaded release notes.',
      );
  }

  @override
  String get name => 'draft';

  @override
  String get description => 'Create a draft Google Play release.';

  @override
  String get invocation => 'boorusama release play draft [--apply] [options]';

  @override
  Future<int> run() async {
    final apply = argResults?['apply'] as bool? ?? false;
    final verbose = argResults?['verbose'] as bool? ?? false;
    final ci = argResults?['ci'] as bool? ?? false;
    final allowDirty = argResults?['allow-dirty'] as bool? ?? false;
    final track = argResults?['track'] as String? ?? 'internal';
    final bundleArg = argResults?['bundle'] as String?;
    final outputDir = Directory(
      argResults?['output-dir'] as String? ?? BoorusamaConfig.defaultOutputDir,
    );
    final releaseNotesLanguage =
        argResults?['release-notes-language'] as String? ?? 'en-US';
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
      final service = PlayDraftService(
        root: root,
        project: project,
        tools: tools,
        logger: logger,
        onProgress: logger.info,
      );
      final plan = await service.plan(
        track: track,
        bundlePath: bundleArg,
        outputDir: outputDir,
        releaseNotesLanguage: releaseNotesLanguage,
        allowDirty: allowDirty,
      );
      const PlayDraftPrinter().printPlan(plan, apply: apply);

      if (!apply) {
        print('');
        print('No changes were made. Run with --apply to create the draft.');
        return 0;
      }

      final result = await service.apply(plan);

      logger.info(
        'Created Google Play draft ${result.versionName}+${result.versionCode} on ${result.track}.',
      );
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
