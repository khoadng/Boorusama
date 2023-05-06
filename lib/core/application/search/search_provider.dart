import 'package:boorusama/core/application/search/filter_operator.dart';
import 'package:boorusama/core/application/search/search_notifier.dart';
import 'package:boorusama/core/application/search/selected_tags_notifier.dart';
import 'package:boorusama/utils/string_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final sanitizedQueryProvider = Provider<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  return query.trimLeft().replaceAll(' ', '_');
});

final filterOperatorProvider = Provider<FilterOperator>((ref) {
  final query = ref.watch(sanitizedQueryProvider);
  return stringToFilterOperator(query.getFirstCharacter());
});

final shouldNotFetchSuggestionsProvider = Provider<bool>((ref) {
  final query = ref.watch(sanitizedQueryProvider);
  final operator = ref.watch(filterOperatorProvider);
  return query.length == 1 && operator != FilterOperator.none;
});

final allowSearchProvider = Provider<bool>((ref) {
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
