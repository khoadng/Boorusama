import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '../builds/codegen.dart';
import '../io/logger.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import '../tool/tool_resolver.dart';
import '../tool/tool_runner.dart';

abstract base class _CodegenCommand extends Command<int> {
  _CodegenCommand() {
    argParser
      ..addFlag(
        'dry-run',
        abbr: 'd',
        negatable: false,
        help: 'Print generator commands without running them.',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        help: 'Enable verbose logging.',
      )
      ..addFlag('ci', abbr: 'c', negatable: false, help: 'Use CI logging.');
  }

  CodegenScope get scope;

  @override
  Future<int> run() => runCodegen(argResults, scope);
}

final class GenCommand extends _CodegenCommand {
  @override
  String get name => 'gen';

  @override
  String get description => 'Generate all repo code.';

  @override
  String get invocation => 'boorusama gen [options]';

  @override
  CodegenScope get scope => CodegenScope.all;
}

final class I18nCommand extends Command<int> {
  I18nCommand() {
    addSubcommand(I18nGenCommand());
  }

  @override
  String get name => 'i18n';

  @override
  String get description => 'Run i18n tooling.';
}

final class I18nGenCommand extends _CodegenCommand {
  @override
  String get name => 'gen';

  @override
  String get description => 'Generate i18n code.';

  @override
  String get invocation => 'boorusama i18n gen [options]';

  @override
  CodegenScope get scope => CodegenScope.i18n;
}

final class BooruCommand extends Command<int> {
  BooruCommand() {
    addSubcommand(BooruGenCommand());
  }

  @override
  String get name => 'booru';

  @override
  String get description => 'Run booru client tooling.';
}

final class BooruGenCommand extends _CodegenCommand {
  @override
  String get name => 'gen';

  @override
  String get description => 'Generate booru client code.';

  @override
  String get invocation => 'boorusama booru gen [options]';

  @override
  CodegenScope get scope => CodegenScope.booru;
}

Future<int> runCodegen(ArgResults? argResults, CodegenScope scope) async {
  final dryRun = argResults?['dry-run'] as bool? ?? false;
  final verbose = argResults?['verbose'] as bool? ?? false;
  final ci = argResults?['ci'] as bool? ?? false;
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
    await Codegen(tools: tools, logger: logger).run(project, scope: scope);
    return 0;
  } on Object catch (error, stackTrace) {
    logger.error(error.toString());
    if (verbose) {
      logger.debug(stackTrace.toString());
    }
    return 1;
  }
}
