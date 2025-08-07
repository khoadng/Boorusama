// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../preparation/version_checking.dart';
import '../types/backup_data_source.dart';
import '../types/types.dart';
import '../utils/backup_utils.dart';
import '../utils/db_transfer.dart';

abstract class SqliteBackupSource implements BackupDataSource {
  SqliteBackupSource({
    required this.id,
    required this.priority,
    required this.ref,
    required this.dbPathGetter,
    required this.dbFileName,
    required this.onImportComplete,
  });

  @override
  final String id;

  @override
  final int priority;

  final Ref ref;
  final Future<String> Function() dbPathGetter;
  final String dbFileName;
  final void Function() onImportComplete;

  @override
  BackupCapabilities get capabilities => BackupCapabilities(
    server: ServerCapability(
      export: _serveDatabase,
      prepareImport: _prepareServerImport,
    ),
    file: FileCapability(
      export: _exportToFile,
      prepareImport: _prepareFileImport,
    ),
    // No clipboard support for binary files
  );

  Future<shelf.Response> _serveDatabase(shelf.Request request) async {
    final dbPath = await dbPathGetter();
    return createDbStreamResponse(
      filePath: dbPath,
      fileName: dbFileName,
    );
  }

  Future<ImportPreparation> _prepareServerImport(
    String serverUrl,
    BuildContext? uiContext,
  ) async {
    return ImportPreparation(
      versionCheck: const VersionCheckInfo(
        result: VersionCheckResult.compatible,
        currentVersion: null,
        importVersion: null,
      ),
      executeImport: () => _executeServerImport(serverUrl),
    );
  }

  Future<void> _executeServerImport(String serverUrl) async {
    final dio = Dio(BaseOptions(baseUrl: serverUrl));
    final dbPath = await dbPathGetter();

    await downloadAndReplaceDb(
      dio: dio,
      url: '/$id',
      filePath: dbPath,
    );

    onImportComplete();
  }

  Future<void> _exportToFile(String directoryPath) async {
    await BackupUtils.ensureStoragePermissions(ref);

    final dbPath = await dbPathGetter();
    final file = File(dbPath);

    if (!file.existsSync()) {
      throw DataExportError(
        error: Exception('No ${displayName.toLowerCase()} found'),
        stackTrace: StackTrace.current,
      );
    }

    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    final fileName = 'boorusama_${id}_$timestamp.db';
    final destinationPath = p.join(directoryPath, fileName);

    await file.copy(destinationPath);
  }

  Future<ImportPreparation> _prepareFileImport(
    String filePath,
    BuildContext? uiContext,
  ) async {
    // Validate SQLite header
    final sourceFile = File(filePath);
    final bytes = await sourceFile.openRead(0, 16).first;
    final header = bytes.take(16).toList();

    if (!_isSQLiteFile(header)) {
      throw const ImportInvalidDatabase();
    }

    return ImportPreparation(
      versionCheck: const VersionCheckInfo(
        result: VersionCheckResult.compatible,
        currentVersion: null,
        importVersion: null,
      ),
      executeImport: () => _executeFileImport(filePath),
    );
  }

  Future<void> _executeFileImport(String sourcePath) async {
    await BackupUtils.ensureStoragePermissions(ref);

    final dbPath = await dbPathGetter();

    await BackupUtils.replaceFile(sourcePath, dbPath);
    onImportComplete();
  }

  // SQLite files start with "SQLite format 3\0"
  bool _isSQLiteFile(List<int> header) {
    const sqliteHeader = [
      0x53,
      0x51,
      0x4C,
      0x69,
      0x74,
      0x65,
      0x20,
      0x66,
      0x6F,
      0x72,
      0x6D,
      0x61,
      0x74,
      0x20,
      0x33,
      0x00,
    ];
    if (header.length < 16) return false;
    for (var i = 0; i < 16; i++) {
      if (header[i] != sqliteHeader[i]) return false;
    }
    return true;
  }
}
