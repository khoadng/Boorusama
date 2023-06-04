// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/search/search.dart';

final searchHistoryRepoProvider =
    Provider<SearchHistoryRepository>((ref) => throw UnimplementedError());

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, SearchHistoryState>((ref) {
  final searchHistoryRepository = ref.watch(searchHistoryRepoProvider);
  return SearchHistoryNotifier(
      searchHistoryRepository: searchHistoryRepository);
}, dependencies: [
  searchHistoryRepoProvider,
]);
