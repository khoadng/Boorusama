// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import '../common.dart';

class SearchKeywordCubit extends Cubit<AsyncLoadState<List<Search>>> {
  SearchKeywordCubit(
    this.popularSearchRepository,
  ) : super(const AsyncLoadState.initial());
  final IPopularSearchRepository popularSearchRepository;

  Future<void> getTags() async => tryAsync<List<Search>>(
      action: () => popularSearchRepository.getSearchByDate(DateTime.now()),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onSuccess: (searches) async {
        if (searches.isEmpty) {
          emit(const AsyncLoadState.loading());
          searches = await popularSearchRepository.getSearchByDate(
              DateTime.now().subtract(const Duration(days: 1)));
        }
        emit(AsyncLoadState.success(searches));
      });
}
