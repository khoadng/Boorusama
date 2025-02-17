// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../../../database/providers.dart';
import '../../../database/utils.dart';
import '../../../foundation/loggers.dart';
import '../types/download_repository.dart';
import 'download_repository_empty.dart';
import 'download_repository_sqlite.dart';

const _kServiceName = 'Download DB';
const kDownloadDbName = 'download.db';

final internalDownloadRepositoryProvider =
    FutureProvider<DownloadRepository>((ref) async {
  final logger = ref.watch(loggerProvider);
  final dbFolderPath = await ref.watch(databaseFolderPathProvider.future);
  final db = await createDb(
    folderPath: dbFolderPath,
    name: kDownloadDbName,
    logger: logger,
  );

  ref.onDispose(() => db?.dispose());

  return _createRepository(logger, db);
});

Future<DownloadRepository> _createRepository(
  Logger? logger,
  Database? db,
) async {
  if (db == null) {
    logger?.logW(_kServiceName, 'Fallback to empty repository');
    return DownloadRepositoryEmpty();
  } else {
    try {
      final sqliteRepo = DownloadRepositorySqlite(db)..initialize();
      return sqliteRepo;
    } on Exception catch (e) {
      logger?.logE(
        _kServiceName,
        'Failed to initialize SQLite repository for download: $e',
      );
      logger?.logW(_kServiceName, 'Fallback to empty repository');

      db.dispose();
      return DownloadRepositoryEmpty();
    }
  }
}
