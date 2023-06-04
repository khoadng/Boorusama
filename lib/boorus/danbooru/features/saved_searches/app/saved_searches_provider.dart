// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/saved_searches/saved_searches.dart';

final danbooruSavedSearchRepoProvider = Provider<SavedSearchRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return SavedSearchRepositoryApi(api, booruConfig);
});

final danbooruSavedSearchesProvider =
    NotifierProvider<SavedSearchesNotifier, List<SavedSearch>?>(
  SavedSearchesNotifier.new,
);

final danbooruSavedSearchAvailableProvider = Provider<List<SavedSearch>>((ref) {
  final savedSearches = ref.watch(danbooruSavedSearchesProvider);

  return [
    SavedSearch.all(),
    ...savedSearches ?? [],
  ];
});

final danbooruSavedSearchSelectedProvider =
    StateProvider.autoDispose<SavedSearch>((ref) {
  ref.listen(
    danbooruSavedSearchesProvider,
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

final danbooruSavedSearchStateProvider =
    FutureProvider.autoDispose<SavedSearchState>((ref) async {
  final savedSearches =
      await ref.watch(danbooruSavedSearchesProvider.notifier).fetch();

  return savedSearches.isEmpty
      ? SavedSearchState.landing
      : SavedSearchState.feed;
});

enum SavedSearchState {
  landing,
  feed,
}
