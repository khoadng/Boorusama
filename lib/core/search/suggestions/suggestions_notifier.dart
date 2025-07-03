// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/debounce_mixin.dart';
import '../../configs/config.dart';
import '../../tags/autocompletes/providers.dart';
import '../../tags/autocompletes/types.dart';
import '../../tags/configs/providers.dart';
import '../queries/filter_operator.dart';
import '../queries/query_utils.dart';

final suggestionsNotifierProvider = NotifierProvider.family<SuggestionsNotifier,
    IMap<String, IList<AutocompleteData>>, BooruConfigAuth>(
  SuggestionsNotifier.new,
);

final fallbackSuggestionsProvider =
    StateProvider.autoDispose<IList<AutocompleteData>>((ref) {
  return <AutocompleteData>[].lock;
});

final suggestionProvider = Provider.autoDispose
    .family<IList<AutocompleteData>, (BooruConfigAuth, String)>(
  (ref, params) {
    final (config, tag) = params;
    final suggestions = ref.watch(suggestionsNotifierProvider(config));
    return suggestions[sanitizeQuery(tag)] ??
        ref.watch(fallbackSuggestionsProvider);
  },
  dependencies: [
    suggestionsNotifierProvider,
    fallbackSuggestionsProvider,
  ],
);

class SuggestionsNotifier extends FamilyNotifier<
    IMap<String, IList<AutocompleteData>>, BooruConfigAuth> with DebounceMixin {
  SuggestionsNotifier() : super();

  @override
  IMap<String, IList<AutocompleteData>> build(BooruConfigAuth arg) {
    return <String, IList<AutocompleteData>>{}.lock;
  }

  void clear() {
    state = <String, IList<AutocompleteData>>{}.lock;
  }

  void getSuggestions(String query) {
    if (query.isEmpty) return;

    final op = getFilterOperator(query);
    final sanitized = sanitizeQuery(query);

    if (sanitized.length == 1 && op != FilterOperator.none) return;

    final fallback = ref.read(fallbackSuggestionsProvider.notifier);
    final autocompleteRepo = ref.read(autocompleteRepoProvider(arg));
    final tagInfo = ref.read(tagInfoProvider);

    // if we already have the suggestions, don't fetch again
    if (state.containsKey(sanitized)) {
      return;
    }

    debounce(
      'suggestions',
      () async {
        final data = await autocompleteRepo
            .getAutocomplete(AutocompleteQuery.text(sanitized));

        final filter = filterNsfw(
          data,
          tagInfo.r18Tags,
          shouldFilter: arg.hasSoftSFW,
        );

        state = state.add(sanitized, filter);

        if (fallback.mounted && fallback.hasListeners) {
          fallback.state = filter;
        }
      },
    );
  }
}
