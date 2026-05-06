import 'dart:io';

import '../io/logger.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';

final class Codegen {
  const Codegen({required this.tools, required this.logger});

  final ToolRunner tools;
  final Logger logger;

  Future<void> run(Project project) async {
    logger.info('Generating code...');
    await Future.wait([
      tools.dart(
        ['run', 'slang'],
        cwd: Directory('${project.root.path}/packages/i18n'),
      ),
      tools.dart(
        ['run', 'tools/generate_language.dart'],
        cwd: Directory('${project.root.path}/packages/i18n'),
      ),
      tools.dart(
        ['run', 'tools/generate_config.dart'],
        cwd: Directory('${project.root.path}/packages/booru_clients'),
      ),
      tools.dart(
        ['run', 'tools/generate_yaml_configs.dart'],
        cwd: Directory('${project.root.path}/packages/booru_clients'),
      ),
      tools.dart(
        ['run', 'tools/generate_registry.dart'],
        cwd: Directory('${project.root.path}/packages/booru_clients'),
      ),
    ]);
    logger.info('Code generation completed.');
  }
}
