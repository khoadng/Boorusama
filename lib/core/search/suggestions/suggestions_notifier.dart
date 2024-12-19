// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../autocompletes/autocompletes.dart';
import '../../autocompletes/providers.dart';
import '../../configs/config.dart';
import '../../configs/current.dart';
import '../../configs/ref.dart';
import '../../foundation/debounce_mixin.dart';
import '../../tags/categories/providers.dart';
import '../../tags/configs/providers.dart';
import '../queries/filter_operator.dart';
import '../queries/query_utils.dart';

final suggestionsNotifierProvider = NotifierProvider.family<SuggestionsNotifier,
    IMap<String, IList<AutocompleteData>>, BooruConfigAuth>(
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
    final booruConfig = ref.watchConfigAuth;
    final suggestions = ref.watch(suggestionsNotifierProvider(booruConfig));
    return suggestions[sanitizeQuery(tag)] ??
        ref.watch(fallbackSuggestionsProvider);
  },
  dependencies: [
    suggestionsNotifierProvider,
    fallbackSuggestionsProvider,
    currentBooruConfigProvider,
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
    final booruTagTypeStore = ref.read(booruTagTypeStoreProvider);
    final tagInfo = ref.read(tagInfoProvider);

    debounce(
      'suggestions',
      () async {
        final data = await autocompleteRepo.getAutocomplete(sanitized);

        await booruTagTypeStore.saveIfNotExist(
          arg.booruType,
          data,
          (tag) => tag.value,
          (tag) => tag.category,
        );

        final filter = filterNsfw(
          data,
          tagInfo.r18Tags,
          shouldFilter: ref.readConfigAuth.hasSoftSFW,
        );

        state = state.add(sanitized, filter);

        if (fallback.mounted && fallback.hasListeners) {
          fallback.state = filter;
        }
      },
    );
  }
}
