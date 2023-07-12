// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/dart.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final sanitizedQueryProvider = Provider.autoDispose<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  final trimmed = query.trim().replaceAll(' ', '_');
  final operator = stringToFilterOperator(trimmed.getFirstCharacter());

  return stripFilterOperator(trimmed, operator);
});

final filterOperatorProvider = Provider.autoDispose<FilterOperator>((ref) {
  final query = ref.watch(searchQueryProvider);
  return stringToFilterOperator(query.trim().getFirstCharacter());
});

final searchMetatagStringRegexProvider = Provider<RegExp>((ref) {
  final metatags = ref.watch(metatagsProvider);
  final metatagString = metatags.map((e) => e.name).join('|');
  return RegExp('($metatagString)+:');
}, dependencies: [
  metatagsProvider,
]);
