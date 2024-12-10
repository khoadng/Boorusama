// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import 'data/search_history_hive_object.dart';
import 'data/search_history_repository.dart';
import 'providers.dart';

Future<Override> createSearchHistoryRepoOverride({
  BootLogger? logger,
}) async {
  logger?.l('Register search history adapter');
  Hive.registerAdapter(SearchHistoryHiveObjectAdapter());

  logger?.l('Initialize search history repository');
  final searchHistoryBox =
      await Hive.openBox<SearchHistoryHiveObject>('search_history');
  final searchHistoryRepo = SearchHistoryRepositoryHive(
    db: searchHistoryBox,
  );

  return searchHistoryRepoProvider.overrideWithValue(searchHistoryRepo);
}
