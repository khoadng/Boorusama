// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/i_popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';
import '../../common.dart';

class SearchKeywordCubit extends Cubit<AsyncLoadState<List<Search>>> {
  SearchKeywordCubit(
    this.popularSearchRepository,
  ) : super(const AsyncLoadState.initial());
  final IPopularSearchRepository popularSearchRepository;

  Future<void> getTags() async => TryAsync<List<Search>>(
      action: () => popularSearchRepository.getSearchByDate(DateTime.now()),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onLoading: () => emit(AsyncLoadState.loading()),
      onSuccess: (searches) async {
        if (searches.isEmpty) {
          emit(AsyncLoadState.loading());
          searches = await popularSearchRepository
              .getSearchByDate(DateTime.now().subtract(Duration(days: 1)));
        }
        emit(AsyncLoadState.success(searches));
      });
}
