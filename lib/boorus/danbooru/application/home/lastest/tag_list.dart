import 'package:boorusama/boorus/danbooru/domain/tags/i_popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SearchKeywordState extends Equatable {
  const SearchKeywordState();
}

class SearchKeywordInitial extends SearchKeywordState {
  const SearchKeywordInitial();

  @override
  List<Object?> get props => ["initial"];
}

class SearchKeywordLoading extends SearchKeywordState {
  const SearchKeywordLoading();
  @override
  List<Object?> get props => ["loading"];
}

class SearchKeywordError extends SearchKeywordState {
  const SearchKeywordError();
  @override
  List<Object?> get props => ["error"];
}

class SearchKeywordLoaded extends SearchKeywordState {
  final List<Search> searches;
  const SearchKeywordLoaded({
    required this.searches,
  });

  @override
  List<Object?> get props => ["loaded", searches];
}

class SearchKeywordCubit extends Cubit<SearchKeywordState> {
  SearchKeywordCubit(
    this.popularSearchRepository,
  ) : super(SearchKeywordInitial());
  final IPopularSearchRepository popularSearchRepository;

  Future<void> getTags() async {
    try {
      emit(SearchKeywordLoading());
      var searches =
          await popularSearchRepository.getSearchByDate(DateTime.now());
      if (searches.isEmpty) {
        searches = await popularSearchRepository
            .getSearchByDate(DateTime.now().subtract(Duration(days: 1)));
      }
      emit(SearchKeywordLoaded(searches: searches));
    } catch (e) {
      emit(SearchKeywordError());
    }
  }
}
