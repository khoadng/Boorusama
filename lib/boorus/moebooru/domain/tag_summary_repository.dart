// Project imports:
import 'package:boorusama/boorus/moebooru/domain/tag_summary.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
