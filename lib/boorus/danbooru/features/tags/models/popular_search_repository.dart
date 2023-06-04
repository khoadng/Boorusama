// Project imports:
import 'package:boorusama/boorus/danbooru/features/tags/models/search.dart';

abstract class PopularSearchRepository {
  Future<List<Search>> getSearchByDate(DateTime date);
}
