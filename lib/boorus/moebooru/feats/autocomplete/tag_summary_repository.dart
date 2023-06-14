// Project imports:
import 'package:boorusama/boorus/moebooru/feats/autocomplete/autocomplete.dart';

abstract class TagSummaryRepository {
  Future<List<TagSummary>> getTagSummaries();
}
