// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/search_stats.dart';

abstract class IPopularSearchRepository {
  Future<List<SearchStats>> getSearchStatsByDate(DateTime date);
}
