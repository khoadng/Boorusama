// Project imports:
import 'tag_summary.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
