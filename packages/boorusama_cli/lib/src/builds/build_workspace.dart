import 'dart:io';

import '../io/logger.dart';

final class BuildWorkspace {
  const BuildWorkspace({required this.root, required this.isTemporary});

  final Directory root;
  final bool isTemporary;

  static Future<BuildWorkspace> createFoss({
    required Directory sourceRoot,
    required Logger logger,
  }) async {
    final workspace = Directory(
      '${sourceRoot.path}/build/boorusama_cli/foss_workspace',
    );

    if (workspace.existsSync()) {
      workspace.deleteSync(recursive: true);
    }
    workspace.createSync(recursive: true);

    logger.info('Creating temporary FOSS workspace: ${workspace.path}');
    _copyDirectory(sourceRoot, workspace, sourceRoot);

    return BuildWorkspace(root: workspace, isTemporary: true);
  }

  Future<void> cleanup(Logger logger) async {
    if (!isTemporary) return;
    if (!root.existsSync()) return;
    logger.info('Removing temporary FOSS workspace: ${root.path}');
    root.deleteSync(recursive: true);
  }

  static void _copyDirectory(
    Directory source,
    Directory target,
    Directory root,
  ) {
    for (final entity in source.listSync(followLinks: false)) {
      final relative = _relativePath(root, entity);
      if (_shouldSkip(relative)) continue;

      final targetPath = '${target.path}/${_basename(entity)}';
      if (entity is Directory) {
        final targetDir = Directory(targetPath)..createSync(recursive: true);
        _copyDirectory(entity, targetDir, root);
      } else if (entity is File) {
        entity.copySync(targetPath);
      }
    }
  }

  static String _basename(FileSystemEntity entity) {
    final parts = entity.path.split(Platform.pathSeparator);
    return parts.lastWhere((part) => part.isNotEmpty);
  }

  static bool _shouldSkip(String relativePath) {
    final normalized = relativePath.replaceAll(r'\', '/');
    final segments = normalized.split('/');
    final name = segments.isEmpty ? normalized : segments.last;

    if (normalized.isEmpty) return false;
    if (name == '.DS_Store') return true;
    if (name.startsWith('pubspec.yaml.backup.')) return true;
    if (name.startsWith('pubspec.lock.backup.')) return true;

    const skippedRoots = {
      '.git',
      '.dart_tool',
      'build',
      'artifacts',
    };
    if (segments.length == 1 && skippedRoots.contains(segments.first)) {
      return true;
    }

    const skippedNested = {
      'android/.gradle',
      'ios/Pods',
      'macos/Pods',
      'packages/boorusama_cli/.dart_tool',
    };
    return skippedNested.any(
      (path) => normalized == path || normalized.startsWith('$path/'),
    );
  }

  static String _relativePath(Directory root, FileSystemEntity entity) {
    final rootPath = root.absolute.path;
    final entityPath = entity.absolute.path;
    if (entityPath == rootPath) return '';
    return entityPath.substring(rootPath.length + 1);
  }
}
