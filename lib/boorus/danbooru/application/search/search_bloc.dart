// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
import 'package:boorusama/core/application/search/tag_search_item.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/search/tag_search_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required DisplayState initial,
    required TagSearchBloc tagSearchBloc,
    required PostBloc postBloc,
    required SearchHistoryCubit searchHistoryCubit,
    required RelatedTagBloc relatedTagBloc,
    required SearchHistorySuggestionsBloc searchHistorySuggestionsBloc,
    String? initialQuery,
  }) : super(SearchState(
          displayState: initial,
          tagSearchState: tagSearchBloc.state,
        )) {
    on<SearchQueryChanged>((event, emit) {
      if (event.query.isEmpty) {
        if (state.displayState != DisplayState.result) {
          emit(state.copyWith(displayState: DisplayState.options));
        }
      } else {
        emit(state.copyWith(displayState: DisplayState.suggestion));
      }

      searchHistorySuggestionsBloc
          .add(SearchHistorySuggestionsFetched(text: event.query));

      tagSearchBloc.add(TagSearchChanged(event.query));
    });

    on<SearchTagSelected>((event, emit) {
      tagSearchBloc.add(TagSearchNewTagSelected(event.tag));
      emit(state.copyWith(displayState: DisplayState.options));
    });

    on<SearchHistoryTagSelected>((event, emit) {
      tagSearchBloc.add(TagSearchTagFromHistorySelected(event.tag));
    });

    on<SearchHistoryDeleted>((event, emit) {
      searchHistoryCubit.removeHistory(event.history.query);
      if (state.displayState == DisplayState.suggestion) {
        searchHistorySuggestionsBloc
            .add(SearchHistorySuggestionsFetched(text: state.currentQuery));
      }
    });

    on<SearchHistoryCleared>((event, emit) {
      searchHistoryCubit.clearHistory();
    });

    on<SearchRequested>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.result));

      final tags = state.selectedTags.map((e) => e.toString()).join(' ');

      add(_SearchRequested(query: tags));
    });

    on<SearchWithRawTagRequested>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.result));

      add(_SearchRequested(query: event.tag));
    });

    on<SearchGoBackToSearchOptionsRequested>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.options));
    });

    on<SearchSelectedTagCleared>((event, emit) {
      tagSearchBloc.add(const TagSearchSelectedTagCleared());
      emit(state.copyWith(displayState: DisplayState.options));
    });

    on<SearchNoData>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.noResult));
    });

    on<SearchError>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.error));
    });

    on<_SearchRequested>((event, emit) {
      searchHistoryCubit.addHistory(event.query);

      relatedTagBloc.add(RelatedTagRequested(query: event.query));

      postBloc.add(PostRefreshed(
        tag: event.query,
        fetcher: SearchedPostFetcher.fromTags(event.query),
      ));
    });

    on<_CopyState>((event, emit) {
      emit(state.copyWith(tagSearchState: event.state));
    });

    tagSearchBloc.stream
        .distinct()
        .listen((event) => add(_CopyState(state: event)))
        .addTo(compositeSubscription);

    if (initialQuery != null && initialQuery.isNotEmpty) {
      tagSearchBloc.add(TagSearchNewRawStringTagSelected(initialQuery));
      add(SearchWithRawTagRequested(initialQuery));
    }

    searchHistoryCubit.getSearchHistory();
  }

  final compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }
}

class _CopyState extends SearchEvent {
  const _CopyState({
    required this.state,
  });

  final TagSearchState state;

  @override
  List<Object?> get props => [state];
}

class _SearchRequested extends SearchEvent {
  const _SearchRequested({
    required this.query,
  });

  final String query;

  @override
  List<Object?> get props => [query];
}
