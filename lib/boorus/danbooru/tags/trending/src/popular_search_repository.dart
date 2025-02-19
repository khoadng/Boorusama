// Project imports:
import 'search.dart';

abstract class PopularSearchRepository {
  Future<List<Search>> getSearchByDate(DateTime date);
}
