// Project imports:
import 'package:boorusama/boorus/moebooru/features/tags/tags.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
