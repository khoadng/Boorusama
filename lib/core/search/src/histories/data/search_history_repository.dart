// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../search_history.dart';
import 'search_history_hive_object.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getHistories();
  Future<List<SearchHistory>> addHistory(
    String query, {
    required QueryType queryType,
  });
  Future<List<SearchHistory>> removeHistory(SearchHistory history);
  Future<bool> clearAll();
}

class SearchHistoryRepositoryHive implements SearchHistoryRepository {
  SearchHistoryRepositoryHive({
    required this.db,
  });

  final Box<SearchHistoryHiveObject> db;

  @override
  Future<List<SearchHistory>> getHistories() async =>
      db.values.map(hiveObjectToSearchHistory).toList();

  @override
  Future<List<SearchHistory>> addHistory(
    String query, {
    required QueryType queryType,
  }) async {
    try {
      if (query.isEmpty) {
        return getHistories();
      }

      if (db.containsKey(query)) {
        final history = hiveObjectToSearchHistory(db.get(query)!);
        final historyObj = searchHistoryToHiveObject(history.copyWith(
          searchCount: history.searchCount + 1,
          createdAt: DateTime.now(),
        ));
        await db.put(query, historyObj);
      } else {
        final history = SearchHistory.now(query, queryType);
        final historyObj = searchHistoryToHiveObject(history);
        await db.put(query, historyObj);
      }

      return getHistories();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> clearAll() async {
    final count = await db.clear();

    return count > 0;
  }

  @override
  Future<List<SearchHistory>> removeHistory(SearchHistory history) async {
    final query = history.query;

    await db.delete(query);

    return getHistories();
  }
}
