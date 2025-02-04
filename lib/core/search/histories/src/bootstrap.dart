// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../../../foundation/path/path_utils.dart';
import 'data/search_history_repository.dart';
import 'providers.dart';

Future<Override> createSearchHistoryRepoOverride({
  BootLogger? logger,
}) async {
  logger?.l('Initialize SQLite database for search history');
  final applicationDocumentsDir = await getApplicationDocumentsDirectory();
  final db =
      sqlite3.open(join(applicationDocumentsDir.path, 'search_history.db'));
  final searchHistoryRepo = SearchHistoryRepositorySqlite(db: db)..initialize();

  return searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo);
}
