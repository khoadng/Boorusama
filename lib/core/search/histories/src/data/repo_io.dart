// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../../foundation/database/providers.dart';
import '../../../../../foundation/database/utils.dart';
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/loggers.dart';
import '../types/search_history_repository.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Search History';
const kSearchHistoryDbName = 'search_history.db';

final searchHistoryRepoProvider = FutureProvider<SearchHistoryRepository>(
  (ref) async {
    final logger = ref.watch(loggerProvider);
    final dbFolderPath = await ref.watch(databaseFolderPathProvider.future);

    final fs = ref.watch(appFileSystemProvider);
    final db = await createDb(
      fs: fs,
      folderPath: dbFolderPath,
      name: kSearchHistoryDbName,
      logger: logger,
    );

    if (db == null) {
      logger.warn(_kServiceName, 'Fallback to empty search history repository');
      return EmptySearchHistoryRepository();
    }

    ref.onDispose(() {
      db.dispose();
    });

    try {
      return SearchHistoryRepositorySqlite(db: db)..initialize();
    } on Exception catch (e) {
      logger
        ..error(
          _kServiceName,
          'Failed to initialize SQLite database for search history: $e',
        )
        ..warn(_kServiceName, 'Fallback to empty search history repository');

      db.dispose();
      return EmptySearchHistoryRepository();
    }
  },
);

Future<String> getSearchHistoryDbPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data', kSearchHistoryDbName);
}
