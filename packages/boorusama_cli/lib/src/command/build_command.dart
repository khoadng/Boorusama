import 'package:args/command_runner.dart';

import '../builds/build_runner.dart';
import '../io/logger.dart';
import '../io/process_runner.dart';
import '../project/project.dart';
import '../tool/tool_resolver.dart';
import '../tool/tool_runner.dart';
import 'build_args_parser.dart';

final class BuildCommand extends Command<int> {
  BuildCommand();

  final _buildArgsParser = BuildArgsParser();

  @override
  String get name => 'build';

  @override
  String get description => 'Build Boorusama artifacts.';

  @override
  String get invocation => 'boorusama build <format> [options]';

  @override
  Future<int> run() => runWithArguments(argResults?.arguments ?? const []);

  Future<int> runWithArguments(List<String> arguments) async {
    if (arguments.contains('-h') || arguments.contains('--help')) {
      print(_buildArgsParser.usage);
      return 0;
    }

    final options = _buildArgsParser.parse(arguments);
    final logger = Logger(verbose: options.verbose, ci: options.ci);
    final processRunner = ProcessRunner(
      logger: logger,
      dryRun: options.dryRun,
    );

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

      await BuildRunner(tools: tools, logger: logger).run(options);
      return 0;
    } on Object catch (error, stackTrace) {
      logger.error(error.toString());
      if (options.verbose) {
        logger.debug(stackTrace.toString());
      }
      return 1;
    }
  }
}
