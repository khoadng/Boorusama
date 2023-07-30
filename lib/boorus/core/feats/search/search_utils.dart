// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/string.dart';

String sanitizeQuery(String query) {
  final trimmed = query.trim().replaceAll(' ', '_');
  final operator = stringToFilterOperator(trimmed.getFirstCharacter());

  return stripFilterOperator(trimmed, operator);
}

FilterOperator getFilterOperator(String query) {
  return stringToFilterOperator(query.trim().getFirstCharacter());
}
