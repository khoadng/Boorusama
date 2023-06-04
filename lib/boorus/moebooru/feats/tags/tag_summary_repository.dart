// Project imports:
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
