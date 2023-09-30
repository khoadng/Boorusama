// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruSavedSearchRepoProvider =
    Provider.family<SavedSearchRepository, BooruConfig>((ref, config) {
  return SavedSearchRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruSavedSearchesProvider = NotifierProvider.family<
    SavedSearchesNotifier, List<SavedSearch>?, BooruConfig>(
  SavedSearchesNotifier.new,
);

final danbooruSavedSearchAvailableProvider =
    Provider.family<List<SavedSearch>, BooruConfig>((ref, config) {
  return [
    SavedSearch.all(),
    ...ref.watch(danbooruSavedSearchesProvider(config)) ?? [],
  ];
});

final danbooruSavedSearchSelectedProvider =
    StateProvider.autoDispose.family<SavedSearch, BooruConfig>((ref, config) {
  ref.listen(
    danbooruSavedSearchesProvider(config),
    (previous, next) {
      if (next == null) return;
      final state = ref.controller.state;
      if (!next.contains(state)) {
        final search = next.firstWhereOrNull((e) => e.id == state.id);
        ref.controller.state = search ?? SavedSearch.all();
      }
    },
  );

  return SavedSearch.all();
});

final danbooruSavedSearchStateProvider = FutureProvider.autoDispose
    .family<SavedSearchState, BooruConfig>((ref, config) async {
  final savedSearches =
      await ref.watch(danbooruSavedSearchesProvider(config).notifier).fetch();

  return savedSearches.isEmpty
      ? SavedSearchState.landing
      : SavedSearchState.feed;
});

enum SavedSearchState {
  landing,
  feed,
}
