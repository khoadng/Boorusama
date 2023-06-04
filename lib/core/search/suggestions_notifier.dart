// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';

final suggestionsProvider =
    NotifierProvider.autoDispose<SuggestionsNotifier, List<AutocompleteData>>(
  SuggestionsNotifier.new,
  dependencies: [autocompleteRepoProvider],
);

final suggestionsQuickSearchProvider =
    NotifierProvider.autoDispose<SuggestionsNotifier, List<AutocompleteData>>(
  SuggestionsNotifier.new,
  dependencies: [autocompleteRepoProvider],
);

final shouldNotFetchSuggestionsProvider = Provider.autoDispose<bool>((ref) {
  final query = ref.watch(sanitizedQueryProvider);
  final operator = ref.watch(filterOperatorProvider);
  return query.length == 1 && operator != FilterOperator.none;
});

class SuggestionsNotifier extends AutoDisposeNotifier<List<AutocompleteData>>
    with DebounceMixin {
  SuggestionsNotifier() : super();

  @override
  List<AutocompleteData> build() {
    return [];
  }

  void getSuggestions(String query) {
    if (ref.read(shouldNotFetchSuggestionsProvider)) {
      return;
    }

    if (query.isEmpty) {
      state = [];
      return;
    }

    debounce(
      'suggestions',
      () async {
        state = await ref.read(autocompleteRepoProvider).getAutocomplete(query);
      },
    );
  }
}
