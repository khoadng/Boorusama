// Dart imports:
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Project imports:
import '../../../foundation/loggers.dart';
import '../../downloads/path/directory.dart';
import '../sources/providers.dart';
import '../types/backup_registry.dart';
import '../zip/bulk_backup_service.dart';
import 'auto_backup_settings.dart';

final autoBackupServiceProvider = Provider<AutoBackupService>((ref) {
  return AutoBackupService(
    bulkBackupService: ref.watch(bulkBackupServiceProvider),
    logger: ref.watch(loggerProvider),
    registry: ref.watch(backupRegistryProvider),
  );
});

class AutoBackupManifest {
  const AutoBackupManifest({
    required this.backups,
  });

  factory AutoBackupManifest.fromJson(Map<String, dynamic> json) {
    return AutoBackupManifest(
      backups: (json['backups'] as List? ?? [])
          .map((e) => AutoBackupEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<AutoBackupEntry> backups;

  Map<String, dynamic> toJson() => {
    'backups': backups.map((e) => e.toJson()).toList(),
  };

  AutoBackupManifest copyWith({
    List<AutoBackupEntry>? backups,
  }) {
    return AutoBackupManifest(
      backups: backups ?? this.backups,
    );
  }
}

class AutoBackupEntry {
  const AutoBackupEntry({
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
  });

  factory AutoBackupEntry.fromJson(Map<String, dynamic> json) {
    return AutoBackupEntry(
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileSize: json['fileSize'] as int,
    );
  }

  final String fileName;
  final DateTime createdAt;
  final int fileSize;

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'createdAt': createdAt.toIso8601String(),
    'fileSize': fileSize,
  };
}

class AutoBackupService {
  const AutoBackupService({
    required this.bulkBackupService,
    required this.logger,
    required this.registry,
  });

  final BulkBackupService bulkBackupService;
  final Logger logger;
  final BackupRegistry registry;

  static const String _manifestFileName = 'auto_backup_manifest.json';
  static const String _backupFolderName = 'boorusama_auto_backups';

  Future<BulkExportResult> performBackup(
    AutoBackupSettings settings, {
    void Function(double progress)? onProgress,
  }) async {
    logger.logI('AutoBackup', 'Starting auto backup');

    final backupDir = await _getBackupDirectory(settings);
    await _cleanupOldBackups(backupDir, settings.maxBackups);

    // Get all available source IDs
    final allSources = registry.getAllSources();
    final sourceIds = allSources.map((source) => source.id).toList();

    final result = await bulkBackupService.exportToZip(
      backupDir.path,
      sourceIds,
      onProgress: onProgress != null
          ? (progressUpdate) => onProgress(progressUpdate.progress)
          : null,
    );

    if (result.success) {
      await _updateManifest(backupDir, result.filePath);

      logger.logI(
        'AutoBackup',
        'Auto backup completed: ${result.exported.length} sources exported',
      );

      if (result.hasFailures) {
        logger.logW(
          'AutoBackup',
          'Some sources failed: ${result.failed.join(', ')}',
        );
      }
    } else {
      logger.logE('AutoBackup', 'Auto backup failed: no sources exported');
    }

    return result;
  }

  Future<Directory> _getBackupDirectory(AutoBackupSettings settings) async {
    final downloadsDirResult = await tryGetDownloadDirectory().run();
    final downloadsDir = downloadsDirResult.fold(
      (error) => null,
      (dir) => dir,
    );

    if (downloadsDir == null) {
      throw Exception('Could not find downloads directory');
    }

    final baseDir = settings.userSelectedPath != null
        ? Directory(settings.userSelectedPath!)
        : downloadsDir;

    final backupDir = Directory(p.join(baseDir.path, _backupFolderName));
    await backupDir.create(recursive: true);
    return backupDir;
  }

  Future<AutoBackupManifest> _loadManifest(Directory backupDir) async {
    final manifestFile = File(p.join(backupDir.path, _manifestFileName));

    if (!manifestFile.existsSync()) {
      return const AutoBackupManifest(backups: []);
    }

    try {
      final content = await manifestFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AutoBackupManifest.fromJson(json);
    } catch (e) {
      logger.logW('AutoBackup', 'Failed to load manifest, creating new: $e');
      return const AutoBackupManifest(backups: []);
    }
  }

  Future<void> _saveManifest(
    Directory backupDir,
    AutoBackupManifest manifest,
  ) async {
    final manifestFile = File(p.join(backupDir.path, _manifestFileName));
    await manifestFile.writeAsString(jsonEncode(manifest.toJson()));
  }

  Future<void> _updateManifest(
    Directory backupDir,
    String newBackupPath,
  ) async {
    final manifest = await _loadManifest(backupDir);
    final backupFile = File(newBackupPath);
    final fileName = p.basename(newBackupPath);
    final fileSize = await backupFile.length();

    final newEntry = AutoBackupEntry(
      fileName: fileName,
      createdAt: DateTime.now(),
      fileSize: fileSize,
    );

    final updatedManifest = manifest.copyWith(
      backups: [...manifest.backups, newEntry],
    );

    await _saveManifest(backupDir, updatedManifest);
  }

  Future<void> _reconcileManifest(Directory backupDir) async {
    final manifest = await _loadManifest(backupDir);
    final actualFiles = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .map((f) => p.basename(f.path))
        .toSet();

    // Remove missing files from manifest
    final validBackups = manifest.backups
        .where((backup) => actualFiles.contains(backup.fileName))
        .toList();

    if (validBackups.length != manifest.backups.length) {
      final removedCount = manifest.backups.length - validBackups.length;
      logger.logI(
        'AutoBackup',
        'Reconciled manifest: removed $removedCount missing entries',
      );
      await _saveManifest(backupDir, AutoBackupManifest(backups: validBackups));
    }
  }

  Future<void> _cleanupOldBackups(Directory backupDir, int maxBackups) async {
    try {
      await _reconcileManifest(backupDir);
      final manifest = await _loadManifest(backupDir);

      if (manifest.backups.length <= maxBackups) return;

      // Sort by creation time (oldest first)
      final sortedBackups = [...manifest.backups]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final backupsToDelete = sortedBackups.take(
        sortedBackups.length - maxBackups,
      );
      final remainingBackups = sortedBackups
          .skip(sortedBackups.length - maxBackups)
          .toList();

      // Delete old backup files
      for (final backup in backupsToDelete) {
        final file = File(p.join(backupDir.path, backup.fileName));
        if (file.existsSync()) {
          await file.delete();
          logger.logI('AutoBackup', 'Deleted old backup: ${backup.fileName}');
        }
      }

      // Update manifest with remaining backups
      final updatedManifest = manifest.copyWith(backups: remainingBackups);
      await _saveManifest(backupDir, updatedManifest);
    } catch (e) {
      logger.logW('AutoBackup', 'Failed to cleanup old backups: $e');
    }
  }
}
