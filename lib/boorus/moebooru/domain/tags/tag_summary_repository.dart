// Project imports:
import 'package:boorusama/boorus/moebooru/domain/tags.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
