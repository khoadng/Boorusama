// Project imports:
import 'package:boorusama/boorus/moebooru/feat/tags/tags.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
