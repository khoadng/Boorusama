// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../foundation/debounce_mixin.dart';
import '../../configs/config/providers.dart';
import '../../configs/config/types.dart';
import '../../tags/autocompletes/providers.dart';
import '../../tags/autocompletes/types.dart';
import '../../tags/configs/providers.dart';
import '../../tags/local/providers.dart';
import '../queries/types.dart';

class SuggestionsNotifier
    extends FamilyNotifier<SuggestionsState, BooruConfigAuth>
    with DebounceMixin {
  SuggestionsNotifier() : super();

  @override
  SuggestionsState build(BooruConfigAuth arg) {
    return SuggestionsState.initial();
  }

  void clear() {
    state = state.clear();
  }

  void setCategory(String? category) {
    if (state.category == category) return;
    state = state.copyWith(
      category: () => category,
      suggestions: <String, IList<AutocompleteData>>{}.lock,
    );
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
    if (state.hasSuggestions(sanitized)) return;

    debounce(
      'suggestions',
      () async {
        final data = await autocompleteRepo.getAutocomplete(
          AutocompleteQuery(
            text: sanitized,
            category: state.category,
          ),
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

        state = state.addSuggestions(sanitized, filter);

        if (fallback.mounted && fallback.hasListeners) {
          fallback.state = filter;
        }
      },
    );
  }
}

class SuggestionsState extends Equatable {
  const SuggestionsState({
    required this.suggestions,
    this.category,
  });

  SuggestionsState.initial()
    : suggestions = <String, IList<AutocompleteData>>{}.lock,
      category = null;

  final IMap<String, IList<AutocompleteData>> suggestions;
  final String? category;

  SuggestionsState copyWith({
    IMap<String, IList<AutocompleteData>>? suggestions,
    String? Function()? category,
  }) => SuggestionsState(
    suggestions: suggestions ?? this.suggestions,
    category: category != null ? category() : this.category,
  );

  SuggestionsState clear() => SuggestionsState.initial();

  bool hasSuggestions(String query) => suggestions.containsKey(query);

  IList<AutocompleteData>? getSuggestionsFor(String query) =>
      suggestions[query];

  SuggestionsState addSuggestions(
    String query,
    IList<AutocompleteData> data,
  ) => copyWith(
    suggestions: suggestions.add(query, data),
  );

  @override
  List<Object?> get props => [suggestions, category];
}

final suggestionsNotifierProvider =
    NotifierProvider.family<
      SuggestionsNotifier,
      SuggestionsState,
      BooruConfigAuth
    >(SuggestionsNotifier.new);

final fallbackSuggestionsProvider =
    StateProvider.autoDispose<IList<AutocompleteData>>((ref) {
      return <AutocompleteData>[].lock;
    });

final suggestionProvider = Provider.autoDispose
    .family<IList<AutocompleteData>, (BooruConfigAuth, String)>(
      (ref, params) {
        final (config, tag) = params;
        final state = ref.watch(suggestionsNotifierProvider(config));
        return state.getSuggestionsFor(sanitizeQuery(tag)) ??
            ref.watch(fallbackSuggestionsProvider);
      },
      dependencies: [
        suggestionsNotifierProvider,
        fallbackSuggestionsProvider,
      ],
    );
