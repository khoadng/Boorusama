// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

class SearchHistoryCubit extends Cubit<AsyncLoadState<List<SearchHistory>>> {
  SearchHistoryCubit({
    required this.searchHistoryRepository,
  }) : super(const AsyncLoadState.initial());

  final ISearchHistoryRepository searchHistoryRepository;

  Future<void> clearHistory() async {
    await tryAsync<bool>(
        action: searchHistoryRepository.clearAll,
        onLoading: () => emit(const AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onSuccess: (success) => emit(const AsyncLoadState.success([])));
  }

  void addHistory(String history) {
    tryAsync<List<SearchHistory>>(
        action: () => searchHistoryRepository.addHistory(history),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onSuccess: (sh) => emit(AsyncLoadState.success(sh)));
  }

  void getSearchHistory() {
    tryAsync<List<SearchHistory>>(
        action: searchHistoryRepository.getHistories,
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onSuccess: (hist) {
          hist.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          emit(AsyncLoadState.success(hist.take(5).toList()));
        });
  }
}
