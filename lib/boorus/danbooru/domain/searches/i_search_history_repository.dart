// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

abstract class ISearchHistoryRepository {
  Future<List<SearchHistory>> getHistories();
  Future<bool> addHistory(String query);
  Future<bool> clearAll();
}
