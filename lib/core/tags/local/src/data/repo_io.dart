// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../../../../../foundation/database/providers.dart';
import '../../../../../foundation/database/utils.dart';
import '../../../../../foundation/loggers.dart';
import '../types/tag_cache_repository.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Tags';
const kTagCacheDbName = 'tags.db';

final tagCacheRepositoryProvider = FutureProvider<TagCacheRepository>(
  (ref) async {
    final logger = ref.watch(loggerProvider);
    final dbFolderPath = await ref.watch(databaseFolderPathProvider.future);

    final db = await createDb(
      folderPath: dbFolderPath,
      name: kTagCacheDbName,
      logger: logger,
    );

    if (db == null) {
      logger.warn(_kServiceName, 'Fallback to empty tag cache repository');
      return EmptyTagCacheRepository();
    }

    final repo = TagCacheRepositorySqlite(db: db);

    ref.onDispose(() {
      repo.dispose();
    });

    try {
      return repo..initialize();
    } on Exception catch (e) {
      logger
        ..error(
          _kServiceName,
          'Failed to initialize SQLite database for tag cache: $e',
        )
        ..warn(_kServiceName, 'Fallback to empty tag cache repository');

      await repo.dispose();
      return EmptyTagCacheRepository();
    }
  },
);

// TODO: should have one place to get the db path in case we want to change it
Future<String> getTagCacheDbPath() async {
  final applicationDocumentsDir = await getApplicationDocumentsDirectory();
  return join(applicationDocumentsDir.path, 'data', kTagCacheDbName);
}
