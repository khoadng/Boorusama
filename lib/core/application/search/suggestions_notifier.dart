import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    state = await ref.read(autocompleteRepoProvider).getAutocomplete(query);
  }
}

mixin SuggestionsNotifierMixin<T> on AutoDisposeNotifier<T> {
  void loadSuggestions(String query) =>
      ref.read(suggestionsProvider.notifier).getSuggestions(query);
}
