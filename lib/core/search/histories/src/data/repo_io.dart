// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../../foundation/database/utils.dart';
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/loggers.dart';
import '../types/search_history_repository.dart';
import '../types/search_history_repository_factory.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Search History';
const kSearchHistoryDbName = 'search_history.db';

final searchHistoryRepositoryFactoryProvider =
    Provider<SearchHistoryRepositoryFactory>(
      (_) => throw UnimplementedError(
        'searchHistoryRepositoryFactoryProvider must be overridden',
      ),
      name: 'searchHistoryRepositoryFactoryProvider',
    );

final searchHistoryRepoProvider = FutureProvider<SearchHistoryRepository>(
  (ref) async {
    final factory = ref.watch(searchHistoryRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
);

final class SqliteSearchHistoryRepositoryFactory
    implements SearchHistoryRepositoryFactory {
  const SqliteSearchHistoryRepositoryFactory({
    required this.fileSystem,
    required this.logger,
  });

  final AppFileSystem fileSystem;
  final Logger logger;

  @override
  Future<SearchHistoryRepository> create() async {
    final dbFolderPath = await getSearchHistoryDbFolderPath(fileSystem);
    final db = await createDb(
      fs: fileSystem,
      folderPath: dbFolderPath,
      name: kSearchHistoryDbName,
      logger: logger,
    );

    if (db == null) {
      logger.warn(_kServiceName, 'Fallback to empty search history repository');
      return EmptySearchHistoryRepository();
    }

    try {
      return SearchHistoryRepositorySqlite(db: db)..initialize();
    } on Exception catch (e) {
      logger
        ..error(
          _kServiceName,
          'Failed to initialize SQLite database for search history: $e',
        )
        ..warn(_kServiceName, 'Fallback to empty search history repository');

      db.close();
      return EmptySearchHistoryRepository();
    }
  }

  @override
  Future<void> dispose(SearchHistoryRepository repository) async {
    if (repository case final SearchHistoryRepositorySqlite sqliteRepository) {
      sqliteRepository.close();
    }
  }
}

SearchHistoryRepositoryFactory createProductionSearchHistoryRepositoryFactory({
  required AppFileSystem fileSystem,
  required Logger logger,
}) => SqliteSearchHistoryRepositoryFactory(
  fileSystem: fileSystem,
  logger: logger,
);

Future<String> getSearchHistoryDbFolderPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data');
}

Future<String> getSearchHistoryDbPath(AppFileSystem fs) async {
  return join(
    await getSearchHistoryDbFolderPath(fs),
    kSearchHistoryDbName,
  );
}
