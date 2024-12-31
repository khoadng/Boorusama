// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import 'filter_operator.dart';

String sanitizeQuery(String query) {
  final trimmed = query.trim().replaceAll(' ', '_');
  final operator = stringToFilterOperator(trimmed.getFirstCharacter());

  return stripFilterOperator(trimmed, operator);
}

FilterOperator getFilterOperator(String query) {
  return stringToFilterOperator(query.trim().getFirstCharacter());
}

extension QueryX on String {
  String? get lastQuery => split(' ').lastOrNull;

  String replaceLastQuery(String newQuery) {
    final currentText = this;
    final lastSpaceIndex = currentText.lastIndexOf(' ');
    final newText = currentText.substring(0, lastSpaceIndex + 1);
    return '$newText$newQuery ';
  }
}
