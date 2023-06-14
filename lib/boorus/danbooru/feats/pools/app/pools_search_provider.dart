part of 'pools_provider.dart';

final danbooruPoolsSearchProvider =
    StateNotifierProvider.autoDispose<PoolsNotifier, PagedState<PoolKey, Pool>>(
        (ref) => PoolsNotifier(
              ref: ref,
              repo: ref.watch(danbooruPoolRepoProvider),
              loadCovers: false,
              nextPageKeyBuilder: (lastItems, page, limit) => null,
            ));

final danbooruPoolsSearchResultProvider =
    StateNotifierProvider.autoDispose<PoolsNotifier, PagedState<PoolKey, Pool>>(
        (ref) => PoolsNotifier(
              ref: ref,
              repo: ref.watch(danbooruPoolRepoProvider),
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
