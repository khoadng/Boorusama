// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../../../../foundation/database/providers.dart';
import '../../../../foundation/database/utils.dart';
import '../../../../foundation/loggers.dart';
import '../types/download_repository.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Download DB';
const kDownloadDbName = 'download.db';

final downloadRepositoryProvider = FutureProvider<DownloadRepository>((
  ref,
) async {
  final repo = await ref.watch(internalDownloadRepositoryProvider.future);

  return repo;
});

final internalDownloadRepositoryProvider = FutureProvider<DownloadRepository>((
  ref,
) async {
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
    logger?.warn(_kServiceName, 'Fallback to empty repository');
    return DownloadRepositoryEmpty();
  } else {
    try {
      final sqliteRepo = DownloadRepositorySqlite(db)..initialize();
      return sqliteRepo;
    } on Exception catch (e) {
      logger?.error(
        _kServiceName,
        'Failed to initialize SQLite repository for download: $e',
      );
      logger?.warn(_kServiceName, 'Fallback to empty repository');

      db.dispose();
      return DownloadRepositoryEmpty();
    }
  }
}

// TODO: should have one place to get the db path in case we want to change it
Future<String> getDownloadsDbPath() async {
  final applicationDocumentsDir = await getApplicationDocumentsDirectory();
  return join(applicationDocumentsDir.path, 'data', kDownloadDbName);
}
