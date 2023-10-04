part of 'pools_provider.dart';

final danbooruPoolsSearchProvider = StateNotifierProvider.autoDispose
    .family<PoolsNotifier, PagedState<PoolKey, Pool>, BooruConfig>(
        (ref, config) => PoolsNotifier(
              ref: ref,
              repo: ref.watch(danbooruPoolRepoProvider(config)),
              loadCovers: false,
              nextPageKeyBuilder: (lastItems, page, limit) => null,
              config: config,
            ));

final danbooruPoolsSearchResultProvider = StateNotifierProvider.autoDispose
    .family<PoolsNotifier, PagedState<PoolKey, Pool>, BooruConfig>(
        (ref, config) => PoolsNotifier(
              ref: ref,
              repo: ref.watch(danbooruPoolRepoProvider(config)),
              config: config,
            ));

final danbooruPoolQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

enum PoolSearchMode {
  suggestion,
  result,
}

final danbooruPoolSearchModeProvider =
    StateProvider.autoDispose<PoolSearchMode>(
        (ref) => PoolSearchMode.suggestion);
