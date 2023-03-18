// Project imports:
import 'package:boorusama/core/domain/searches/searches.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getHistories();
  Future<List<SearchHistory>> addHistory(String query);
  Future<List<SearchHistory>> removeHistory(String query);
  Future<bool> clearAll();
}
