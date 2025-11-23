// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/providers.dart';
import '../../selected_tags/selected_tag_controller.dart';
import '../../selected_tags/types.dart';
import 'data/providers.dart';
import 'types/search_history.dart';

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, SearchHistoryState>(
      SearchHistoryNotifier.new,
    );

class SearchHistoryNotifier extends AsyncNotifier<SearchHistoryState> {
  @override
  Future<SearchHistoryState> build() async {
    final repo = await ref.watch(searchHistoryRepoProvider.future);
    final histories = await repo.getHistories();

    return SearchHistoryState.initial().copyWith(
      histories: histories,
      filteredHistories: histories,
    );
  }

  Future<void> clearHistories() async {
    final repo = await ref.read(searchHistoryRepoProvider.future);
    final success = await repo.clearAll();

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

    final repo = await ref.read(searchHistoryRepoProvider.future);

    final histories = await repo.addHistory(
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

    final repo = await ref.read(searchHistoryRepoProvider.future);

    final histories = await repo.removeHistory(history);

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

    final filteredHistories = currentState.histories
        .where((e) => e.query.contains(pattern))
        .toList();
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

class SearchHistoryState {
  SearchHistoryState({
    required this.histories,
    required this.filteredHistories,
    required this.currentQuery,
  });

  SearchHistoryState.initial()
    : histories = [],
      filteredHistories = [],
      currentQuery = '';

  final List<SearchHistory> histories;
  final List<SearchHistory> filteredHistories;
  final String currentQuery;

  SearchHistoryState copyWith({
    List<SearchHistory>? histories,
    List<SearchHistory>? filteredHistories,
    String? currentQuery,
  }) {
    return SearchHistoryState(
      histories: histories ?? this.histories,
      filteredHistories: filteredHistories ?? this.filteredHistories,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}
