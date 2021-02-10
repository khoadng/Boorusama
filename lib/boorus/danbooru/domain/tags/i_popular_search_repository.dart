// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';

abstract class IPopularSearchRepository {
  Future<List<Search>> getSearchByDate(DateTime date);
}
