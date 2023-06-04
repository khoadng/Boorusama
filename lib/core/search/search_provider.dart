// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/utils/string_utils.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final sanitizedQueryProvider = Provider.autoDispose<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  return query.trimLeft().replaceAll(' ', '_');
});

final filterOperatorProvider = Provider.autoDispose<FilterOperator>((ref) {
  final query = ref.watch(sanitizedQueryProvider);
  return stringToFilterOperator(query.getFirstCharacter());
});

final allowSearchProvider = Provider.autoDispose<bool>((ref) {
  final displayState = ref.watch(searchProvider);
  final selectedTags = ref.watch(selectedTagsProvider);

  if (displayState == DisplayState.options) {
    return selectedTags.isNotEmpty;
  }
  if (displayState == DisplayState.suggestion) return false;

  return false;
}, dependencies: [
  searchProvider,
  selectedTagsProvider,
]);

final searchMetatagStringRegexProvider = Provider<RegExp>((ref) {
  final metatags = ref.watch(metatagsProvider);
  final metatagString = metatags.map((e) => e.name).join('|');
  return RegExp('($metatagString)+:');
}, dependencies: [
  metatagsProvider,
]);
