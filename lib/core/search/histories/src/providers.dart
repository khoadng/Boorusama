// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../selected_tags/selected_tag_controller.dart';
import 'data/search_history_repository.dart';
import 'search_history.dart';
import 'search_history_state.dart';

final searchHistoryRepoProvider =
    Provider<SearchHistoryRepository>((ref) => throw UnimplementedError());

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, SearchHistoryState>(
  SearchHistoryNotifier.new,
);

class SearchHistoryNotifier extends AsyncNotifier<SearchHistoryState> {
  @override
  Future<SearchHistoryState> build() async {
    final histories = await ref.watch(searchHistoryRepoProvider).getHistories();

    return SearchHistoryState.initial().copyWith(
      histories: histories,
      filteredHistories: histories,
    );
  }

  Future<void> clearHistories() async {
    final success = await ref.read(searchHistoryRepoProvider).clearAll();

    if (success) {
      state = AsyncData(SearchHistoryState.initial());
    }
  }

  Future<void> addHistoryFromController(
    SelectedTagController controller,
  ) async {
    final anyRaw = controller.tags.any((e) => e.isRaw);

    if (anyRaw) {
      await addHistory(
        controller.rawTagsString,
      );
      return;
    }

    final queries = controller.tags.map((e) => e.originalTag).toList();

    if (queries.isEmpty) return;

    final json = jsonEncode(queries);

    await addHistory(json, queryType: QueryType.list);
  }

  Future<void> addHistory(
    String history, {
    QueryType queryType = QueryType.simple,
  }) async {
    // ignore empty history
    if (history.trim().isEmpty) return;

    final currentState = state.value;

    if (currentState == null) return;

    final config = ref.readConfigAuth;

    final histories = await ref.read(searchHistoryRepoProvider).addHistory(
          history,
          queryType: queryType,
          siteUrl: Uri.tryParse(config.url)?.host ?? '',
          booruTypeName: config.booruType.name,
        );

    state = AsyncData(
      currentState.copyWith(
        histories: histories,
      ),
    );

    filterHistories(currentState.currentQuery);
  }

  Future<void> removeHistory(SearchHistory history) async {
    final currentState = state.value;

    if (currentState == null) return;

    final histories =
        await ref.read(searchHistoryRepoProvider).removeHistory(history);

    state = AsyncData(
      currentState.copyWith(
        histories: histories,
      ),
    );

    filterHistories(currentState.currentQuery);
  }

  void filterHistories(String pattern) {
    final currentState = state.value;

    if (currentState == null) return;

    final filteredHistories =
        currentState.histories.where((e) => e.query.contains(pattern)).toList();
    state = AsyncData(
      currentState.copyWith(
        currentQuery: pattern,
        filteredHistories: filteredHistories,
      ),
    );
  }

  void resetFilter() {
    final query = state.value?.currentQuery ?? '';

    if (query.isEmpty) return;

    state = const AsyncLoading();

    filterHistories('');
  }
}
