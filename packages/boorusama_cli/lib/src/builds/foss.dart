import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

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
    required bool offline,
    required Project project,
    required Future<T> Function(Project project, ToolRunner tools) body,
  }) async {
    if (!enabled) {
      if (offline) {
        logger.info('Resolving dependencies from the local cache...');
        await tools.flutter(['pub', 'get', '--offline']);
      }
      return body(project, tools);
    }

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
      if (offline) {
        _writeOfflineOverrides(project.root, workspaceProject.root);
      }

      logger.info('Getting FOSS dependencies in temporary workspace...');
      await workspaceTools.flutter([
        'pub',
        'get',
        if (offline) '--offline',
      ]);

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

  void _writeOfflineOverrides(Directory sourceRoot, Directory targetRoot) {
    final lockFile = File('${sourceRoot.path}/pubspec.lock');
    final packageConfig = File(
      '${sourceRoot.path}/.dart_tool/package_config.json',
    );
    if (!lockFile.existsSync() || !packageConfig.existsSync()) return;

    final lock = loadYaml(lockFile.readAsStringSync()) as YamlMap;
    final lockedPackages = lock['packages'] as YamlMap?;
    if (lockedPackages == null) return;

    for (final entity in targetRoot.listSync(recursive: true)) {
      if (entity is File &&
          entity.uri.pathSegments.last == 'pubspec_overrides.yaml') {
        entity.deleteSync();
      }
    }

    final externalPackages =
        <String>{
          for (final entry in lockedPackages.entries)
            if ((entry.value as YamlMap)['source'] == 'git' ||
                (entry.value as YamlMap)['source'] == 'hosted')
              entry.key as String,
        }..removeAll(
          BoorusamaConfig.fossExcludedDeps.map(
            (dependency) => dependency.substring(0, dependency.length - 1),
          ),
        );

    final config = jsonDecode(packageConfig.readAsStringSync()) as Map;
    final configUri = packageConfig.parent.uri;
    final paths = <String, String>{};
    for (final package in (config['packages'] as List).cast<Map>()) {
      final name = package['name'] as String;
      if (!externalPackages.contains(name)) continue;
      paths[name] = configUri
          .resolve(package['rootUri'] as String)
          .toFilePath();
    }
    if (paths.isEmpty) return;

    final names = paths.keys.toList()..sort();
    final content = StringBuffer('dependency_overrides:\n');
    for (final name in names) {
      content
        ..writeln('  $name:')
        ..writeln('    path: ${jsonEncode(paths[name])}');
    }
    File(
      '${targetRoot.path}/pubspec_overrides.yaml',
    ).writeAsStringSync(content.toString());
  }
}
