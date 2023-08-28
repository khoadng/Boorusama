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
    StateProvider.autoDispose<IList<AutocompleteData>>((ref) {
  return <AutocompleteData>[].lock;
});

final suggestionProvider =
    Provider.autoDispose.family<IList<AutocompleteData>, String>(
  (ref, tag) {
    final suggestions = ref.watch(suggestionsProvider);
    return suggestions[sanitizeQuery(tag)] ??
        ref.watch(fallbackSuggestionsProvider);
  },
  dependencies: [
    suggestionsProvider,
    fallbackSuggestionsProvider,
  ],
);

class SuggestionsNotifier
    extends Notifier<IMap<String, IList<AutocompleteData>>> with DebounceMixin {
  SuggestionsNotifier() : super();

  @override
  IMap<String, IList<AutocompleteData>> build() {
    ref.watch(currentBooruConfigProvider);

    return <String, IList<AutocompleteData>>{}.lock;
  }

  void getSuggestions(String query) {
    if (query.isEmpty) return;

    final op = getFilterOperator(query);
    final sanitized = sanitizeQuery(query);

    if (sanitized.length == 1 && op != FilterOperator.none) return;

    if (state.containsKey(sanitized)) return;

    final fallback = ref.read(fallbackSuggestionsProvider.notifier);
    final autocompleteRepo = ref.read(autocompleteRepoProvider);

    debounce(
      'suggestions',
      () async {
        final data = await autocompleteRepo.getAutocomplete(sanitized);
        state = state.add(sanitized, data.lock);

        if (fallback.hasListeners) {
          fallback.state = data.lock;
        }
      },
      duration: const Duration(milliseconds: 200),
    );
  }
}
