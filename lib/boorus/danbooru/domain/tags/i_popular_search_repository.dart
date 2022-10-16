// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';

abstract class PopularSearchRepository {
  Future<List<Search>> getSearchByDate(DateTime date);
}
