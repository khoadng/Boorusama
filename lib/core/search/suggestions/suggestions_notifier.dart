// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/debounce_mixin.dart';
import '../../configs/config.dart';
import '../../configs/config/providers.dart';
import '../../tags/autocompletes/providers.dart';
import '../../tags/autocompletes/types.dart';
import '../../tags/configs/providers.dart';
import '../../tags/local/providers.dart';
import '../queries/filter_operator.dart';
import '../queries/query_utils.dart';

final suggestionsNotifierProvider =
    NotifierProvider.family<
      SuggestionsNotifier,
      IMap<String, IList<AutocompleteData>>,
      BooruConfigAuth
    >(
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

class SuggestionsNotifier
    extends
        FamilyNotifier<IMap<String, IList<AutocompleteData>>, BooruConfigAuth>
    with DebounceMixin {
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
    final loginDetails = ref.read(booruLoginDetailsProvider(arg));

    // if we already have the suggestions, don't fetch again
    if (state.containsKey(sanitized)) {
      return;
    }

    debounce(
      'suggestions',
      () async {
        final data = await autocompleteRepo.getAutocomplete(
          AutocompleteQuery.text(sanitized),
        );

        var filter = filterNsfw(
          data,
          tagInfo.r18Tags,
          shouldFilter: loginDetails.hasSoftSFW,
        );

        if (filter.isNotEmpty) {
          final tagCache = await ref.read(tagCacheRepositoryProvider.future);
          final result = await tagCache.resolveTags(
            arg.url,
            filter.map((e) => e.value).toList(),
          );

          if (result.found.isNotEmpty) {
            final found = {
              for (final tag in result.found) tag.tagName: tag,
            };

            filter = filter
                .map((e) {
                  final cachedTag = found[e.value];
                  return cachedTag != null ? e.resolveCached(cachedTag) : e;
                })
                .toList()
                .lock;
          }
        }

        state = state.add(sanitized, filter);

        if (fallback.mounted && fallback.hasListeners) {
          fallback.state = filter;
        }
      },
    );
  }
}

//   AutocompleteData _resolveCached(AutocompleteData autocomplete, CachedTag tag) {
//     return autocomplete.copyWith(
//  type: autocomplete.type ?? tag.category,
//  postCount: tag.postCount,
//     );

//   }
