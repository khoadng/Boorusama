// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../../../foundation/path/path_utils.dart';
import 'data/empty_search_history_repository.dart';
import 'data/search_history_repository.dart';
import 'data/search_history_repository_sqlite.dart';
import 'providers.dart';

const _kServiceName = 'Search History';
const kSearchHistoryDbName = 'search_history.db';

Future<Override> createSearchHistoryRepoOverride({
  BootLogger? bootLogger,
  Logger? logger,
}) async {
  bootLogger?.l('Initialize SQLite database for search history');

  final searchHistoryRepo = await _createRepo(logger: logger);

  return searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo);
}

Future<Database?> _createDb(
  Logger? logger,
) async {
  try {
    final applicationDocumentsDir = await getApplicationDocumentsDirectory();
    final dbFolderPath = join(applicationDocumentsDir.path, 'data');
    // Make sure the directory exists
    await Directory(dbFolderPath).create(recursive: true);

    return sqlite3.open(join(dbFolderPath, kSearchHistoryDbName));
  } on Exception catch (e) {
    logger?.logE(
      _kServiceName,
      'Failed to initialize SQLite database for search history: $e',
    );
    return null;
  }
}

Future<SearchHistoryRepository> _createRepo({
  Logger? logger,
}) async {
  final db = await _createDb(logger);

  if (db == null) {
    logger?.logW(_kServiceName, 'Fallback to empty search history repository');
    return EmptySearchHistoryRepository();
  }

  try {
    return SearchHistoryRepositorySqlite(db: db)..initialize();
  } on Exception catch (e) {
    logger?.logE(
      _kServiceName,
      'Failed to initialize SQLite database for search history: $e',
    );
    logger?.logW(_kServiceName, 'Fallback to empty search history repository');

    db.dispose();
    return EmptySearchHistoryRepository();
  }
}

// TODO: should have one place to get the db path in case we want to change it
Future<String> getSearchHistoryDbPath() async {
  final applicationDocumentsDir = await getApplicationDocumentsDirectory();
  return join(applicationDocumentsDir.path, 'data', kSearchHistoryDbName);
}
