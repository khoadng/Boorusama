import 'dart:io';

import '../io/logger.dart';
import '../settings/generation.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';

enum CodegenScope { all, i18n, booru, settings }

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
        await _validateI18n(project);
        await Future.wait([
          _generateI18n(project),
          _runBooruClients(project),
          _runSettings(project),
        ]);
        logger.info('Code generation completed.');
      case CodegenScope.i18n:
        logger.info('Generating i18n code...');
        await _runI18n(project);
        logger.info('i18n code generation completed.');
      case CodegenScope.settings:
        await _runSettings(project);
      case CodegenScope.booru:
        logger.info('Generating booru client code...');
        await _runBooruClients(project);
        logger.info('Booru client code generation completed.');
    }
  }

  Future<void> _runSettings(Project project) async {
    final changed = await SettingsGeneration().run(
      project.root,
      dryRun: tools.processRunner.dryRun,
    );
    logger.info(
      '${tools.processRunner.dryRun ? 'Would generate' : 'Generated'} ${changed.length} settings files.',
    );
  }

  Future<void> _runI18n(Project project) async {
    await _validateI18n(project);
    await _generateI18n(project);
  }

  Future<void> _validateI18n(Project project) => tools.dart(
    ['run', 'i18n_cli:booru_i18n', 'validate'],
    cwd: project.root,
  );

  Future<void> _generateI18n(Project project) => Future.wait([
    tools.dart(
      ['run', 'slang'],
      cwd: Directory('${project.root.path}/packages/i18n'),
    ),
    tools.dart(
      ['run', 'tools/generate_language.dart'],
      cwd: Directory('${project.root.path}/packages/i18n'),
    ),
  ]);

  Future<void> _runBooruClients(Project project) => Future.wait([
    for (final script in [
      'generate_config',
      'generate_yaml_configs',
      'generate_registry',
    ])
      tools.dart(
        ['run', 'tools/$script.dart'],
        cwd: Directory('${project.root.path}/packages/booru_clients'),
      ),
  ]);
}
