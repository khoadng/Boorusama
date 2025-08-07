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
import '../sources/providers.dart';
import '../types/backup_data_source.dart';
import '../types/backup_registry.dart';
import '../types/types.dart';
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
    ref: ref,
  );
});

class BulkBackupService {
  const BulkBackupService({
    required this.registry,
    required this.appVersion,
    required this.ref,
  });

  final BackupRegistry registry;
  final Version? appVersion;
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
    await BackupUtils.ensureStoragePermissions(ref);

    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    final zipFileName = 'boorusama_backup_$timestamp.zip';
    final zipPath = p.join(directoryPath, zipFileName);

    final tempDir = await Directory.systemTemp.createTemp('boorusama_backup_');

    try {
      // Filter sources by provided IDs
      final allSources = registry.getAllSources();
      final selectedSources = allSources
          .where((source) => sourceIds.contains(source.id))
          .toList();

      final sourceFiles = <String, String>{};
      final failed = <String>[];

      // Export each selected source to temp directory
      for (final source in selectedSources) {
        final result = await _exportSource(source, tempDir);
        result.fold(
          (error) => failed.add(source.id),
          (fileName) => sourceFiles[source.id] = fileName,
        );
      }

      // Add any requested source IDs that don't exist in registry
      final existingSourceIds = allSources.map((s) => s.id).toSet();
      final missingSourceIds = sourceIds.where(
        (id) => !existingSourceIds.contains(id),
      );
      failed.addAll(missingSourceIds);

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

      await _createZipWithProgress(tempDir.path, zipPath, onProgress);

      return BulkExportResult(
        success: sourceFiles.isNotEmpty,
        exported: sourceFiles.keys.toList(),
        failed: failed,
        filePath: zipPath,
      );
    } catch (e, st) {
      throw DataExportError(error: e, stackTrace: st);
    } finally {
      // Cleanup temp directory
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {
        // Ignore cleanup errors
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
    await BackupUtils.ensureStoragePermissions(ref);

    final tempDir = await Directory.systemTemp.createTemp('boorusama_import_');

    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final extractedFile = File(p.join(tempDir.path, filename));
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(data);
        }
      }

      // Read manifest
      final manifestFile = File(p.join(tempDir.path, _manifestFileName));
      if (!manifestFile.existsSync()) {
        throw const ImportInvalidJsonField();
      }

      final manifestContent = await manifestFile.readAsString();
      final manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
      final manifest = BulkBackupManifest.fromJson(manifestJson);

      // Determine sources to process
      final sourcesToProcess = onlySourceIds != null
          ? manifest.sources.where((id) => onlySourceIds.contains(id)).toList()
          : manifest.sources;

      final imported = <String>[];
      final failed = <String>[];
      final skipped = <String>[];

      // Check for requested sources not in zip
      if (onlySourceIds != null) {
        final zipSourceIds = manifest.sources.toSet();
        final notInZip = onlySourceIds.where(
          (id) => !zipSourceIds.contains(id),
        );
        failed.addAll(notInZip);
      }

      // Import each available source
      for (final sourceId in sourcesToProcess) {
        try {
          final source = registry.getSource(sourceId);
          if (source == null) {
            skipped.add(sourceId);
            continue;
          }

          final fileCapability = source.capabilities.file;
          if (fileCapability == null) {
            skipped.add(sourceId);
            continue;
          }

          // Get exact filename from manifest
          final fileName = manifest.sourceFiles[sourceId];
          if (fileName == null) {
            failed.add(sourceId);
            continue;
          }

          final sourceFile = File(p.join(tempDir.path, fileName));
          if (!sourceFile.existsSync()) {
            failed.add(sourceId);
            continue;
          }

          if (uiContext == null || !uiContext.mounted) {
            failed.add(sourceId);
            continue;
          }

          final preparation = await fileCapability.prepareImport(
            sourceFile.path,
            uiContext,
          );

          await preparation.executeImport();
          imported.add(sourceId);
        } catch (e) {
          failed.add(sourceId);
        }
      }

      return BulkImportResult(
        success: imported.isNotEmpty,
        imported: imported,
        failed: failed,
        skipped: skipped,
      );
    } catch (e, st) {
      if (e is ImportError) rethrow;
      throw DataExportError(error: e, stackTrace: st);
    } finally {
      // Cleanup temp directory
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {
        // Ignore cleanup errors
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
