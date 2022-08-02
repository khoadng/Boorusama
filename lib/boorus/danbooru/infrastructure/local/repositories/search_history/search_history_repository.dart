// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'search_history_hive_object.dart';

class SearchHistoryRepository implements ISearchHistoryRepository {
  SearchHistoryRepository({
    required this.db,
  });

  final Box<SearchHistoryHiveObject> db;

  @override
  Future<List<SearchHistory>> getHistories() async =>
      db.values.map(hiveObjectToSearchHistory).toList();

  @override
  Future<List<SearchHistory>> addHistory(String query) async {
    try {
      if (query.isEmpty) {
        return getHistories();
      }

      final history = SearchHistory.now(query);
      final historyObj = searchHistoryToHiveObject(history);
      await db.put(query, historyObj);

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
}
