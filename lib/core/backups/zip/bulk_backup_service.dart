// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:version/version.dart';

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../../foundation/loggers.dart';
import '../sources/providers.dart';
import '../types/backup_data_source.dart';
import '../types/backup_registry.dart';
import '../utils/backup_utils.dart';

class BulkBackupManifest {
  const BulkBackupManifest({
    required this.version,
    required this.appVersion,
    required this.exportDate,
    required this.sourceFiles,
    required this.failed,
  });

  factory BulkBackupManifest.fromJson(Map<String, dynamic> json) {
    return BulkBackupManifest(
      version: json['version'] as int,
      appVersion: json['appVersion'] as String?,
      exportDate: DateTime.parse(json['exportDate'] as String),
      sourceFiles: Map<String, String>.from(json['sourceFiles'] as Map? ?? {}),
      failed: List<String>.from(json['failed'] as List? ?? []),
    );
  }

  final int version;
  final String? appVersion;
  final DateTime exportDate;
  final Map<String, String> sourceFiles; // sourceId -> filename
  final List<String> failed;

  List<String> get sources => sourceFiles.keys.toList();

  Map<String, dynamic> toJson() => {
    'version': version,
    if (appVersion != null) 'appVersion': appVersion,
    'exportDate': exportDate.toIso8601String(),
    'sourceFiles': sourceFiles,
    'failed': failed,
  };
}

class BulkExportResult {
  const BulkExportResult({
    required this.success,
    required this.exported,
    required this.failed,
    required this.filePath,
  });

  final bool success;
  final List<String> exported;
  final List<String> failed;
  final String filePath;

  bool get hasFailures => failed.isNotEmpty;
  int get totalSources => exported.length + failed.length;
}

class ZipCreationMessage {
  const ZipCreationMessage({
    required this.tempDirPath,
    required this.zipPath,
    required this.sendPort,
  });

  final String tempDirPath;
  final String zipPath;
  final SendPort sendPort;
}

class ZipProgressUpdate {
  const ZipProgressUpdate({
    required this.filesProcessed,
    required this.totalFiles,
    required this.isComplete,
    this.error,
  });

  final int filesProcessed;
  final int totalFiles;
  final bool isComplete;
  final String? error;

  double get progress => totalFiles > 0 ? filesProcessed / totalFiles : 0.0;
}

class BulkImportResult {
  const BulkImportResult({
    required this.success,
    required this.imported,
    required this.failed,
    required this.skipped,
  });

  final bool success;
  final List<String> imported;
  final List<String> failed;
  final List<String> skipped;

  bool get hasFailures => failed.isNotEmpty;
  int get totalProcessed => imported.length + failed.length + skipped.length;
}

final bulkBackupServiceProvider = Provider<BulkBackupService>((ref) {
  return BulkBackupService(
    registry: ref.watch(backupRegistryProvider),
    appVersion: ref.watch(appVersionProvider),
    logger: ref.watch(loggerProvider),
    ref: ref,
  );
});

class BulkBackupService {
  const BulkBackupService({
    required this.registry,
    required this.appVersion,
    required this.logger,
    required this.ref,
  });

  final BackupRegistry registry;
  final Version? appVersion;
  final Logger logger;
  final Ref ref;

  static const int _manifestVersion = 1;
  static const String _manifestFileName = 'manifest.json';

  // Isolate entry point for zip creation
  static Future<void> _createZipInIsolate(ZipCreationMessage message) async {
    try {
      final tempDir = Directory(message.tempDirPath);
      final files = tempDir
          .listSync(recursive: true)
          .whereType<File>()
          .toList();
      final totalFiles = files.length;

      final encoder = ZipFileEncoder()..create(message.zipPath);

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final relativePath = p.relative(file.path, from: tempDir.path);
        await encoder.addFile(file, relativePath);

        // Send progress update
        message.sendPort.send(
          ZipProgressUpdate(
            filesProcessed: i + 1,
            totalFiles: totalFiles,
            isComplete: false,
          ),
        );
      }

      await encoder.close();

      // Send completion
      message.sendPort.send(
        const ZipProgressUpdate(
          filesProcessed: 0,
          totalFiles: 0,
          isComplete: true,
        ),
      );
    } catch (e) {
      message.sendPort.send(
        ZipProgressUpdate(
          filesProcessed: 0,
          totalFiles: 0,
          isComplete: true,
          error: e.toString(),
        ),
      );
    }
  }

  Future<BulkExportResult> exportToZip(
    String directoryPath,
    List<String> sourceIds, {
    void Function(ZipProgressUpdate)? onProgress,
  }) async {
    logger.logI(
      'Backup.Export',
      'Starting export to zip for ${sourceIds.length} sources: ${sourceIds.join(', ')}',
    );

    await BackupUtils.ensureStoragePermissions(ref);

    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    final zipFileName = 'boorusama_backup_$timestamp.zip';
    final zipPath = p.join(directoryPath, zipFileName);

    logger.logI('Backup.Export', 'Export target: $zipPath');

    final tempDir = await Directory.systemTemp.createTemp('boorusama_backup_');
    logger.logI('Backup.Export', 'Created temp directory: ${tempDir.path}');

    try {
      // Filter sources by provided IDs
      final allSources = registry.getAllSources();
      final selectedSources = allSources
          .where((source) => sourceIds.contains(source.id))
          .toList();

      logger.logI(
        'Backup.Export',
        'Found ${selectedSources.length} sources to export from ${allSources.length} total sources',
      );

      final sourceFiles = <String, String>{};
      final failed = <String>[];

      // Export each selected source to temp directory
      for (final source in selectedSources) {
        logger.logI('Backup.Export', 'Exporting source: ${source.id}');
        final result = await _exportSource(source, tempDir);
        result.fold(
          (error) {
            logger.logE(
              'Backup.Export',
              'Failed to export source ${source.id}: $error',
            );
            failed.add(source.id);
          },
          (fileName) {
            logger.logI(
              'Backup.Export',
              'Successfully exported source ${source.id} to $fileName',
            );
            sourceFiles[source.id] = fileName;
          },
        );
      }

      // Add any requested source IDs that don't exist in registry
      final existingSourceIds = allSources.map((s) => s.id).toSet();
      final missingSourceIds = sourceIds.where(
        (id) => !existingSourceIds.contains(id),
      );
      if (missingSourceIds.isNotEmpty) {
        logger.logW(
          'Backup.Export',
          'Missing source IDs not found in registry: ${missingSourceIds.join(', ')}',
        );
        failed.addAll(missingSourceIds);
      }

      logger.logI(
        'Backup.Export',
        'Export summary: ${sourceFiles.length} successful, ${failed.length} failed',
      );

      // Create manifest
      final manifest = BulkBackupManifest(
        version: _manifestVersion,
        appVersion: appVersion?.toString(),
        exportDate: DateTime.now(),
        sourceFiles: sourceFiles,
        failed: failed,
      );

      final manifestFile = File(p.join(tempDir.path, _manifestFileName));
      await manifestFile.writeAsString(jsonEncode(manifest.toJson()));
      logger
        ..logI('Backup.Export', 'Created manifest file')
        ..logI('Backup.Export', 'Starting zip creation');
      await _createZipWithProgress(tempDir.path, zipPath, onProgress);
      logger.logI('Backup.Export', 'Zip creation completed');

      return BulkExportResult(
        success: sourceFiles.isNotEmpty,
        exported: sourceFiles.keys.toList(),
        failed: failed,
        filePath: zipPath,
      );
    } catch (e) {
      logger.logE('Backup.Export', 'Export failed with exception: $e');
      rethrow;
    } finally {
      // Cleanup temp directory
      try {
        await tempDir.delete(recursive: true);
        logger.logI('Backup.Export', 'Cleaned up temp directory');
      } catch (e) {
        logger.logW('Backup.Export', 'Failed to cleanup temp directory: $e');
      }
    }
  }

  Future<Either<ExportException, FileName>> _exportSource(
    BackupDataSource source,
    Directory tempDir,
  ) async {
    try {
      final fileCapability = source.capabilities.file;
      if (fileCapability == null) {
        return left(const ExportException('No file export capability'));
      }

      // Get files before export
      final filesBefore = _getDirectoryFiles(tempDir);

      await fileCapability.export(tempDir.path);

      // Get files after export to find what was created
      final filesAfter = _getDirectoryFiles(tempDir);
      final newFiles = filesAfter
          .where((f) => !filesBefore.contains(f))
          .toList();

      if (newFiles.isEmpty) {
        return left(const ExportException('No files created during export'));
      }

      // Use the first new file (sources should only create one file)
      return right(p.basename(newFiles.first));
    } catch (e) {
      return left(ExportException('Export failed: $e'));
    }
  }

  List<String> _getDirectoryFiles(Directory dir) {
    return dir.listSync().whereType<File>().map((f) => f.path).toList();
  }

  Future<void> _createZipWithProgress(
    String tempDirPath,
    String zipPath,
    void Function(ZipProgressUpdate)? onProgress,
  ) async {
    final receivePort = ReceivePort();
    final completer = Completer<void>();

    receivePort.listen((data) {
      if (data is ZipProgressUpdate) {
        if (onProgress != null) {
          onProgress(data);
        }

        if (data.isComplete) {
          receivePort.close();
          if (data.error != null) {
            completer.completeError(Exception(data.error));
          } else {
            completer.complete();
          }
        }
      }
    });

    await Isolate.spawn(
      _createZipInIsolate,
      ZipCreationMessage(
        tempDirPath: tempDirPath,
        zipPath: zipPath,
        sendPort: receivePort.sendPort,
      ),
    );

    await completer.future;
  }

  Future<BulkImportResult> importFromZip(
    String zipPath,
    BuildContext? uiContext, {
    List<String>? onlySourceIds,
  }) async {
    final sourceFilter = onlySourceIds != null
        ? 'filtering for ${onlySourceIds.join(', ')}'
        : 'all sources';
    logger.logI(
      'Backup.Import',
      'Starting import from zip: $zipPath - $sourceFilter',
    );

    await BackupUtils.ensureStoragePermissions(ref);

    final tempDir = await Directory.systemTemp.createTemp('boorusama_import_');
    logger.logI(
      'Backup.Import',
      'Created temp directory for import: ${tempDir.path}',
    );

    try {
      final bytes = await File(zipPath).readAsBytes();
      logger.logI('Backup.Import', 'Read ${bytes.length} bytes from zip file');

      final archive = ZipDecoder().decodeBytes(bytes);
      logger.logI(
        'Backup.Import',
        'Decoded zip archive with ${archive.length} files',
      );

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final extractedFile = File(p.join(tempDir.path, filename));
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(data);
        }
      }
      logger.logI('Backup.Import', 'Extracted all files from archive');

      // Read manifest
      final manifestFile = File(p.join(tempDir.path, _manifestFileName));
      if (!manifestFile.existsSync()) {
        logger.logE(
          'Backup.Import',
          'Manifest file not found: $_manifestFileName',
        );
        throw Exception(
          'Manifest file not found in zip: $_manifestFileName',
        );
      }

      final manifestContent = await manifestFile.readAsString();
      final manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
      final manifest = BulkBackupManifest.fromJson(manifestJson);

      logger.logI(
        'Backup.Import',
        'Loaded manifest with ${manifest.sources.length} sources: ${manifest.sources.join(', ')}',
      );

      // Determine sources to process
      final sourcesToProcess = onlySourceIds != null
          ? manifest.sources.where((id) => onlySourceIds.contains(id)).toList()
          : manifest.sources;

      logger.logI(
        'Backup.Import',
        'Processing ${sourcesToProcess.length} sources: ${sourcesToProcess.join(', ')}',
      );

      final imported = <String>[];
      final failed = <String>[];
      final skipped = <String>[];

      // Check for requested sources not in zip
      if (onlySourceIds != null) {
        final zipSourceIds = manifest.sources.toSet();
        final notInZip = onlySourceIds.where(
          (id) => !zipSourceIds.contains(id),
        );
        if (notInZip.isNotEmpty) {
          logger.logW(
            'Backup.Import',
            'Requested sources not found in zip: ${notInZip.join(', ')}',
          );
          failed.addAll(notInZip);
        }
      }

      // Import each available source
      for (final sourceId in sourcesToProcess) {
        logger.logI('Backup.Import', 'Processing source: $sourceId');

        try {
          final source = registry.getSource(sourceId);
          if (source == null) {
            logger.logW(
              'Backup.Import',
              'Source not found in registry, skipping: $sourceId',
            );
            skipped.add(sourceId);
            continue;
          }

          final fileCapability = source.capabilities.file;
          if (fileCapability == null) {
            logger.logW(
              'Backup.Import',
              'Source has no file capability, skipping: $sourceId',
            );
            skipped.add(sourceId);
            continue;
          }

          // Get exact filename from manifest
          final fileName = manifest.sourceFiles[sourceId];
          if (fileName == null) {
            logger.logE(
              'Backup.Import',
              'No filename found in manifest for source: $sourceId',
            );
            failed.add(sourceId);
            continue;
          }

          final sourceFile = File(p.join(tempDir.path, fileName));
          if (!sourceFile.existsSync()) {
            logger.logE(
              'Backup.Import',
              'Source file does not exist: $fileName for source: $sourceId',
            );
            failed.add(sourceId);
            continue;
          }

          if (uiContext == null || !uiContext.mounted) {
            logger.logE(
              'Backup.Import',
              'UI context not available for source: $sourceId',
            );
            failed.add(sourceId);
            continue;
          }

          logger.logI(
            'Backup.Import',
            'Preparing import for source $sourceId from file: $fileName',
          );
          final preparation = await fileCapability.prepareImport(
            sourceFile.path,
            uiContext,
          );

          await preparation.executeImport();
          logger.logI(
            'Backup.Import',
            'Successfully imported source: $sourceId',
          );
          imported.add(sourceId);
        } catch (e) {
          logger.logE('Backup.Import', 'Failed to import source $sourceId: $e');
          failed.add(sourceId);
        }
      }

      logger.logI(
        'Backup.Import',
        'Import completed: ${imported.length} imported, ${failed.length} failed, ${skipped.length} skipped',
      );

      return BulkImportResult(
        success: imported.isNotEmpty,
        imported: imported,
        failed: failed,
        skipped: skipped,
      );
    } catch (e) {
      logger.logE('Backup.Import', 'Import failed with exception: $e');
      rethrow;
    } finally {
      // Cleanup temp directory
      try {
        await tempDir.delete(recursive: true);
        logger.logI('Backup.Import', 'Cleaned up temp directory');
      } catch (e) {
        logger.logW('Backup.Import', 'Failed to cleanup temp directory: $e');
      }
    }
  }
}

class ExportException implements Exception {
  const ExportException(this.message);

  final String message;

  @override
  String toString() => 'ExportException: $message';
}

typedef FileName = String;
