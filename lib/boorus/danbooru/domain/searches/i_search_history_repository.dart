// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

abstract class ISearchHistoryRepository {
  Future<List<SearchHistory>> getHistories();
  Future<List<SearchHistory>> addHistory(String query);
  Future<bool> clearAll();
}
