// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/tags/booru_tag_type_store.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/functional.dart';

final suggestionsProvider = NotifierProvider.family<SuggestionsNotifier,
    IMap<String, IList<AutocompleteData>>, BooruConfig>(
  SuggestionsNotifier.new,
  dependencies: [
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
    final booruConfig = ref.watchConfig;
    final suggestions = ref.watch(suggestionsProvider(booruConfig));
    return suggestions[sanitizeQuery(tag)] ??
        ref.watch(fallbackSuggestionsProvider);
  },
  dependencies: [
    suggestionsProvider,
    fallbackSuggestionsProvider,
    currentBooruConfigProvider,
  ],
);

class SuggestionsNotifier
    extends FamilyNotifier<IMap<String, IList<AutocompleteData>>, BooruConfig>
    with DebounceMixin {
  SuggestionsNotifier() : super();

  @override
  IMap<String, IList<AutocompleteData>> build(BooruConfig arg) {
    return <String, IList<AutocompleteData>>{}.lock;
  }

  void getSuggestions(String query) {
    if (query.isEmpty) return;

    final op = getFilterOperator(query);
    final sanitized = sanitizeQuery(query);

    if (sanitized.length == 1 && op != FilterOperator.none) return;

    if (state.containsKey(sanitized)) return;

    final fallback = ref.read(fallbackSuggestionsProvider.notifier);
    final booruBuilder = ref.read(booruBuilderProvider);
    final autocompleteFetcher = booruBuilder?.autocompleteFetcher;
    final booruTagTypeStore = ref.read(booruTagTypeStoreProvider);

    debounce(
      'suggestions',
      () async {
        final data = await (autocompleteFetcher?.call(sanitized) ??
            Future.value(<AutocompleteData>[]));

        await booruTagTypeStore.saveAutocompleteIfNotExist(arg.booruType, data);

        state = state.add(sanitized, data.lock);

        if (fallback.mounted && fallback.hasListeners) {
          fallback.state = data.lock;
        }
      },
      duration: const Duration(milliseconds: 200),
    );
  }
}
