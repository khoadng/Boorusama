// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/functional.dart';

final suggestionsProvider = NotifierProvider<SuggestionsNotifier,
    IMap<String, IList<AutocompleteData>>>(
  SuggestionsNotifier.new,
  dependencies: [
    autocompleteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final fallbackSuggestionsProvider =
    StateProvider<IList<AutocompleteData>>((ref) {
  return <AutocompleteData>[].lock;
});

final suggestionProvider = Provider.family<IList<AutocompleteData>, String>(
  (ref, tag) {
    final suggestions = ref.watch(suggestionsProvider);
    return suggestions[tag] ?? ref.watch(fallbackSuggestionsProvider);
  },
  dependencies: [
    suggestionsProvider,
  ],
);

final suggestionsQuickSearchProvider = NotifierProvider<SuggestionsNotifier,
    IMap<String, IList<AutocompleteData>>>(
  SuggestionsNotifier.new,
  dependencies: [
    autocompleteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final suggestionQuickSearchProvider =
    Provider.family<IList<AutocompleteData>, String>(
  (ref, tag) {
    final suggestions = ref.watch(suggestionsQuickSearchProvider);
    return suggestions[tag] ?? <AutocompleteData>[].lock;
  },
  dependencies: [suggestionsQuickSearchProvider],
);

final shouldNotFetchSuggestionsProvider = Provider.autoDispose<bool>((ref) {
  final query = ref.watch(sanitizedQueryProvider);
  final operator = ref.watch(filterOperatorProvider);
  return query.length == 1 && operator != FilterOperator.none;
});

class SuggestionsNotifier
    extends Notifier<IMap<String, IList<AutocompleteData>>> with DebounceMixin {
  SuggestionsNotifier() : super();

  @override
  IMap<String, IList<AutocompleteData>> build() {
    ref.watch(currentBooruConfigProvider);

    return <String, IList<AutocompleteData>>{}.lock;
  }

  void getSuggestions(String query) {
    if (state.containsKey(query)) return;
    if (ref.read(shouldNotFetchSuggestionsProvider)) return;
    if (query.isEmpty) return;

    debounce(
      'suggestions',
      () async {
        final data =
            await ref.read(autocompleteRepoProvider).getAutocomplete(query);
        state = state.add(query, data.lock);
        ref.read(fallbackSuggestionsProvider.notifier).state = data.lock;
      },
      duration: const Duration(milliseconds: 200),
    );
  }
}
