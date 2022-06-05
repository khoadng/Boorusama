// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/i_search_history_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

class SearchHistoryCubit extends Cubit<AsyncLoadState<List<SearchHistory>>> {
  SearchHistoryCubit({
    required this.searchHistoryRepository,
  }) : super(AsyncLoadState.initial());

  final ISearchHistoryRepository searchHistoryRepository;

  void clearHistory() async {
    TryAsync<bool>(
        action: () => searchHistoryRepository.clearAll(),
        onLoading: () => emit(AsyncLoadState.loading()),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onSuccess: (success) => emit(AsyncLoadState.success([])));
  }

  void addHistory(String history) {
    TryAsync<List<SearchHistory>>(
        action: () => searchHistoryRepository.addHistory(history),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onLoading: () => emit(AsyncLoadState.loading()),
        onSuccess: (sh) => emit(AsyncLoadState.success(sh)));
  }

  void getSearchHistory() {
    TryAsync<List<SearchHistory>>(
        action: () => searchHistoryRepository.getHistories(),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onLoading: () => emit(AsyncLoadState.loading()),
        onSuccess: (hist) {
          hist.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          emit(AsyncLoadState.success(hist.take(5).toList()));
        });
  }
}
