// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/provider.dart';

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

class SuggestionsNotifier extends AutoDisposeNotifier<List<AutocompleteData>> {
  SuggestionsNotifier() : super();

  @override
  List<AutocompleteData> build() {
    return [];
  }

  void getSuggestions(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    state = await ref.watch(autocompleteRepoProvider).getAutocomplete(query);
  }
}
