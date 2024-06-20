// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';

part 'search_history_hive_object.g.dart';

@HiveType(typeId: 1)
class SearchHistoryHiveObject {
  SearchHistoryHiveObject({
    required this.query,
    required this.createdAt,
    required this.searchCount,
  });

  @HiveField(0)
  String query;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int? searchCount;
}

SearchHistory hiveObjectToSearchHistory(SearchHistoryHiveObject obj) {
  return SearchHistory(
    query: obj.query,
    createdAt: obj.createdAt,
    searchCount: obj.searchCount ?? 0,
  );
}

SearchHistoryHiveObject searchHistoryToHiveObject(SearchHistory history) {
  return SearchHistoryHiveObject(
    query: history.query,
    createdAt: history.createdAt,
    searchCount: history.searchCount,
  );
}
