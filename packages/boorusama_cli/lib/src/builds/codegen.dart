import 'dart:io';

import '../io/logger.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';

enum CodegenScope { all, i18n, booru }

final class Codegen {
  const Codegen({required this.tools, required this.logger});

  final ToolRunner tools;
  final Logger logger;

  Future<void> run(
    Project project, {
    CodegenScope scope = CodegenScope.all,
  }) async {
    switch (scope) {
      case CodegenScope.all:
        logger.info('Generating code...');
        await _runI18n(project);
        await _runBooruClients(project);
        logger.info('Code generation completed.');
      case CodegenScope.i18n:
        logger.info('Generating i18n code...');
        await _runI18n(project);
        logger.info('i18n code generation completed.');
      case CodegenScope.booru:
        logger.info('Generating booru client code...');
        await _runBooruClients(project);
        logger.info('Booru client code generation completed.');
    }
  }

  Future<void> _runI18n(Project project) async {
    await tools.dart(
      ['run', 'slang'],
      cwd: Directory('${project.root.path}/packages/i18n'),
    );
    await tools.dart(
      ['run', 'tools/generate_language.dart'],
      cwd: Directory('${project.root.path}/packages/i18n'),
    );
  }

  Future<void> _runBooruClients(Project project) async {
    await tools.dart(
      ['run', 'tools/generate_config.dart'],
      cwd: Directory('${project.root.path}/packages/booru_clients'),
    );
    await tools.dart(
      ['run', 'tools/generate_yaml_configs.dart'],
      cwd: Directory('${project.root.path}/packages/booru_clients'),
    );
    await tools.dart(
      ['run', 'tools/generate_registry.dart'],
      cwd: Directory('${project.root.path}/packages/booru_clients'),
    );
  }
}
