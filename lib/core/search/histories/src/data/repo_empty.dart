// Project imports:
import '../../../selected_tags/types.dart';
import '../types/search_history.dart';
import '../types/search_history_repository.dart';

class EmptySearchHistoryRepository implements SearchHistoryRepository {
  @override
  Future<List<SearchHistory>> addHistory(
    String query, {
    required QueryType queryType,
    required String booruTypeName,
    required String siteUrl,
  }) {
    return getHistories();
  }

  @override
  Future<bool> clearAll() async {
    return true;
  }

  @override
  Future<List<SearchHistory>> getHistories() async {
    return [];
  }

  @override
  Future<List<SearchHistory>> removeHistory(SearchHistory history) {
    return getHistories();
  }
}
