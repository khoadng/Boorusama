// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getHistories();
  Future<List<SearchHistory>> addHistory(String query);
  Future<bool> clearAll();
}
