import 'dart:async';
import 'dart:io';

import '../io/logger.dart';
import '../project/config.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'foss_backups.dart';

final class FossBuild {
  FossBuild({required this.tools, required this.logger});

  final ToolRunner tools;
  final Logger logger;

  File? _pubspecBackup;
  File? _lockBackup;
  File? _pubspec;
  File? _lock;
  bool _hadLock = false;
  bool _restored = false;
  StreamSubscription<ProcessSignal>? _sigintSubscription;
  StreamSubscription<ProcessSignal>? _sigtermSubscription;

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
    required Future<T> Function() body,
  }) async {
    if (!enabled) return body();

    _createBackups(project);
    _installSignalHandlers();

    try {
      logger.info('Preparing FOSS build - removing non-FOSS dependencies...');
      _rewritePubspecForFoss();

      logger.info('Getting FOSS dependencies...');
      await tools.flutter(['pub', 'get']);

      return await body();
    } finally {
      await _removeSignalHandlers();
      _restoreBackups();
    }
  }

  void _createBackups(Project project) {
    final pubspec = File('${project.root.path}/pubspec.yaml');
    final lock = File('${project.root.path}/pubspec.lock');
    final stamp = '${DateTime.now().millisecondsSinceEpoch}.${pid}';

    _pubspec = pubspec;
    _lock = lock;
    _pubspecBackup = File('${pubspec.path}.backup.$stamp');
    _lockBackup = File('${lock.path}.backup.$stamp');
    _hadLock = lock.existsSync();
    _restored = false;

    pubspec.copySync(_pubspecBackup!.path);
    if (_hadLock) lock.copySync(_lockBackup!.path);
  }

  void _rewritePubspecForFoss() {
    final pubspec = _pubspec;
    if (pubspec == null) return;

    var content = pubspec.readAsStringSync();
    for (final dep in BoorusamaConfig.fossExcludedDeps) {
      content = content
          .split('\n')
          .where((line) => !line.trimLeft().startsWith(dep))
          .join('\n');
    }
    pubspec.writeAsStringSync(content);
  }

  void _installSignalHandlers() {
    if (!ProcessSignal.sigint.watch().isBroadcast) {
      // ProcessSignal streams are broadcast on supported platforms; this branch
      // is only here to keep the assumption explicit.
    }

    _sigintSubscription = ProcessSignal.sigint.watch().listen((_) {
      logger.warning('Interrupted. Restoring FOSS build backups...');
      _restoreBackups();
      exit(130);
    });

    if (!Platform.isWindows) {
      _sigtermSubscription = ProcessSignal.sigterm.watch().listen((_) {
        logger.warning('Terminated. Restoring FOSS build backups...');
        _restoreBackups();
        exit(143);
      });
    }
  }

  Future<void> _removeSignalHandlers() async {
    await _sigintSubscription?.cancel();
    await _sigtermSubscription?.cancel();
    _sigintSubscription = null;
    _sigtermSubscription = null;
  }

  void _restoreBackups() {
    if (_restored) return;
    _restored = true;

    final pubspec = _pubspec;
    final lock = _lock;
    final pubspecBackup = _pubspecBackup;
    final lockBackup = _lockBackup;

    if (pubspec != null &&
        pubspecBackup != null &&
        pubspecBackup.existsSync()) {
      pubspecBackup.renameSync(pubspec.path);
    }

    if (_hadLock &&
        lock != null &&
        lockBackup != null &&
        lockBackup.existsSync()) {
      lockBackup.renameSync(lock.path);
    }

    logger.info('Restored original pubspec files');
  }
}
