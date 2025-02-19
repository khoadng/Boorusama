// Project imports:
import '../search_history.dart';

const String kSearchHistoryTable = 'search_history';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getHistories();
  Future<List<SearchHistory>> addHistory(
    String query, {
    required QueryType queryType,
    required String booruTypeName,
    required String siteUrl,
  });
  Future<List<SearchHistory>> removeHistory(SearchHistory history);
  Future<bool> clearAll();
}
