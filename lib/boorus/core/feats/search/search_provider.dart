// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/dart.dart';

String sanitizeQuery(String query) {
  final trimmed = query.trim().replaceAll(' ', '_');
  final operator = stringToFilterOperator(trimmed.getFirstCharacter());

  return stripFilterOperator(trimmed, operator);
}

FilterOperator getFilterOperator(String query) {
  return stringToFilterOperator(query.trim().getFirstCharacter());
}

final searchMetatagStringRegexProvider = Provider<RegExp>((ref) {
  final metatags = ref.watch(metatagsProvider);
  final metatagString = metatags.map((e) => e.name).join('|');
  return RegExp('($metatagString)+:');
}, dependencies: [
  metatagsProvider,
]);
