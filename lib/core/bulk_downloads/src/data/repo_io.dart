// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../foundation/database/utils.dart';
import '../../../../foundation/filesystem.dart';
import '../../../../foundation/loggers.dart';
import '../types/download_repository.dart';
import '../types/download_repository_factory.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Download DB';
const kDownloadDbName = 'download.db';

final downloadRepositoryFactoryProvider = Provider<DownloadRepositoryFactory>(
  (ref) => SqliteDownloadRepositoryFactory(
    fileSystem: ref.watch(appFileSystemProvider),
    logger: ref.watch(loggerProvider),
  ),
);

final downloadRepositoryProvider = FutureProvider<DownloadRepository>(
  (ref) => ref.watch(internalDownloadRepositoryProvider.future),
);

final internalDownloadRepositoryProvider = FutureProvider<DownloadRepository>(
  (ref) async {
    final factory = ref.watch(downloadRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
);

final class SqliteDownloadRepositoryFactory
    implements DownloadRepositoryFactory {
  const SqliteDownloadRepositoryFactory({
    required this.fileSystem,
    required this.logger,
  });

  final AppFileSystem fileSystem;
  final Logger logger;

  @override
  Future<DownloadRepository> create() async {
    final dbFolderPath = await getDownloadDbFolderPath(fileSystem);
    final db = await createDb(
      fs: fileSystem,
      folderPath: dbFolderPath,
      name: kDownloadDbName,
      logger: logger,
    );

    if (db == null) {
      logger.warn(_kServiceName, 'Fallback to empty repository');
      return DownloadRepositoryEmpty();
    }

    try {
      return DownloadRepositorySqlite(db)..initialize();
    } on Exception catch (e) {
      logger
        ..error(
          _kServiceName,
          'Failed to initialize SQLite repository for download: $e',
        )
        ..warn(_kServiceName, 'Fallback to empty repository');

      db.close();
      return DownloadRepositoryEmpty();
    }
  }

  @override
  Future<void> dispose(DownloadRepository repository) async {
    if (repository case final DownloadRepositorySqlite sqliteRepository) {
      sqliteRepository.db.close();
    }
  }
}

Future<String> getDownloadDbFolderPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data');
}

Future<String> getDownloadsDbPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data', kDownloadDbName);
}
