part of 'pools_provider.dart';

final danbooruPoolQueryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

enum PoolSearchMode {
  suggestion,
  result,
}

final danbooruPoolSearchModeProvider =
    StateProvider.autoDispose<PoolSearchMode>(
        (ref) => PoolSearchMode.suggestion);
