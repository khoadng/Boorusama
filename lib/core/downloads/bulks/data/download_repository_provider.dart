// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../types/download_repository.dart';
import 'download_repository_memory.dart';
import 'download_repository_sqlite.dart';

const _kServiceName = 'Download DB';

final internalDownloadRepositoryProvider =
    FutureProvider<DownloadRepository>((ref) async {
  final logger = ref.watch(loggerProvider);
  final db = await _createDb(logger);

  DownloadRepository repo;

  if (db == null) {
    logger.logW(_kServiceName, 'Fallback to memory repository');
    repo = DownloadRepositoryMemory();
  } else {
    final sqliteRepo = DownloadRepositorySqlite(db)..initialize();
    repo = sqliteRepo;
  }

  return repo;
});

Future<Database?> _createDb(
  Logger? logger,
) async {
  try {
    final applicationDocumentsDir = await getApplicationDocumentsDirectory();
    final dbFolderPath = join(applicationDocumentsDir.path, 'data');
    // Make sure the directory exists
    await Directory(dbFolderPath).create(recursive: true);

    return sqlite3.open(join(dbFolderPath, 'download.db'));
  } on Exception catch (e) {
    logger?.logE(
      _kServiceName,
      'Failed to initialize SQLite database for search history: $e',
    );
    return null;
  }
}
