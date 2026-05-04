import 'dart:io';

import '../io/logger.dart';
import '../project/config.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'build_workspace.dart';
import 'foss_backups.dart';

final class FossBuild {
  FossBuild({required this.tools, required this.logger});

  final ToolRunner tools;
  final Logger logger;

  static void warnAboutLeftoverBackups(Project project, Logger logger) {
    final backups = FossBackups.find(project.root);

    if (backups.isEmpty) return;

    logger.warning(
      'Found leftover FOSS backup files. A previous build may not have cleaned up: ${backups.map(FossBackups.displayName).join(', ')}',
    );
  }

  Future<T> guard<T>({
    required bool enabled,
    required Project project,
    required Future<T> Function(Project project, ToolRunner tools) body,
  }) async {
    if (!enabled) return body(project, tools);

    final workspace = await BuildWorkspace.createFoss(
      sourceRoot: project.root,
      logger: logger,
    );
    final workspaceTools = tools.withRoot(workspace.root);

    try {
      final workspaceProject = Project(
        root: workspace.root,
        pubspec: project.pubspec,
        env: project.env,
        git: project.git,
      );

      logger.info('Preparing FOSS build - removing non-FOSS dependencies...');
      _rewritePubspecForFoss(workspaceProject.root);

      logger.info('Getting FOSS dependencies in temporary workspace...');
      await workspaceTools.flutter(['pub', 'get']);

      return await body(workspaceProject, workspaceTools);
    } finally {
      await workspace.cleanup(logger);
    }
  }

  void _rewritePubspecForFoss(Directory root) {
    final pubspec = File('${root.path}/pubspec.yaml');
    var content = pubspec.readAsStringSync();
    for (final dep in BoorusamaConfig.fossExcludedDeps) {
      content = content
          .split('\n')
          .where((line) => !line.trimLeft().startsWith(dep))
          .join('\n');
    }
    pubspec.writeAsStringSync(content);
  }
}
