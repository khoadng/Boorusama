import 'package:args/command_runner.dart';

import '../../io/logger.dart';
import '../../io/process_runner.dart';
import '../../project/project.dart';
import '../../release/git_release.dart';
import '../../release/prepare/printer.dart';
import '../../release/prepare/service.dart';
import '../../tool/tool_resolver.dart';
import '../../tool/tool_runner.dart';

final class ReleasePrepareCommand extends Command<int> {
  ReleasePrepareCommand() {
    argParser
      ..addFlag('apply', negatable: false)
      ..addFlag('verbose', abbr: 'v', negatable: false)
      ..addFlag('ci', abbr: 'c', negatable: false);
  }

  @override
  String get name => 'prepare';

  @override
  String get description => 'Prepare a release branch and pubspec version.';

  @override
  String get invocation => 'boorusama release prepare <version> [--apply]';

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
      final project = await Project.load(root: root, env: env, tools: tools);
      final git = GitRelease(tools);
      final prepare = ReleasePrepareService(
        root: root,
        project: project,
        git: git,
        onProgress: logger.info,
      );
      const printer = ReleasePreparePrinter();
      final plan = await prepare.plan(versionName);

      printer.printPlan(plan, apply: apply);
      printer.printDiffPreview(plan);
      prepare.validate(plan);

      if (!apply) {
        print('');
        print('No changes were made. Run with --apply to prepare the release.');
        return 0;
      }

      await prepare.apply(plan);
      print('');
      print(
        'Release branch prepared. Review, update changelog if needed, then commit.',
      );
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (verbose) logger.debug(stackTrace.toString());
      return 1;
    }
  }
}
