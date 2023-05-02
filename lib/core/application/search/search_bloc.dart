// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/search_history.dart' as sh;
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required DisplayState initial,
    required TagSearchBloc tagSearchBloc,
    required sh.SearchHistoryBloc searchHistoryBloc,
    required sh.SearchHistorySuggestionsBloc searchHistorySuggestionsBloc,
    required List<Metatag> metatags,
    required BooruType booruType,
    String? initialQuery,
  }) : super(SearchState(
          displayState: initial,
          tagSearchState: tagSearchBloc.state,
          metatags: metatags,
          totalResults: 0,
        )) {
    on<SearchQueryChanged>((event, emit) {
      if (event.query.isEmpty) {
        if (state.displayState != DisplayState.result) {
          add(const SearchGoBackToSearchOptionsRequested());
        }
      } else {
        emit(state.copyWith(displayState: DisplayState.suggestion));
      }

      searchHistorySuggestionsBloc
          .add(sh.SearchHistorySuggestionsFetched(text: event.query));

      tagSearchBloc.add(TagSearchChanged(event.query));
    });

    on<SearchQuerySubmitted>((event, emit) {
      tagSearchBloc.add(const TagSearchSubmitted());

      if (state.displayState == DisplayState.suggestion) {
        add(const SearchGoBackToSearchOptionsRequested());
      }
    });

    on<SearchTagSelected>((event, emit) {
      tagSearchBloc.add(TagSearchNewTagSelected(event.tag));

      if (state.displayState == DisplayState.suggestion) {
        add(const SearchGoBackToSearchOptionsRequested());
      }
    });

    on<SearchRawTagSelected>((event, emit) {
      tagSearchBloc.add(TagSearchNewRawStringTagSelected(event.tag));
    });

    on<SearchRawMetatagSelected>((event, emit) {
      final query = '${event.tag}:';
      add(SearchQueryChanged(query: query));
    });

    on<SearchHistoryTagSelected>((event, emit) {
      tagSearchBloc.add(TagSearchTagFromHistorySelected(event.tag));

      if (state.displayState == DisplayState.suggestion) {
        add(const SearchGoBackToSearchOptionsRequested());
      }
    });

    on<SearchHistoryDeleted>((event, emit) {
      searchHistoryBloc.add(sh.SearchHistoryRemoved(event.history.query));
      if (state.displayState == DisplayState.suggestion) {
        searchHistorySuggestionsBloc
            .add(sh.SearchHistorySuggestionsFetched(text: state.currentQuery));
      }
    });

    on<SearchHistoryCleared>((event, emit) {
      searchHistoryBloc.add(const sh.SearchHistoryCleared());
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
      tagSearchBloc.add(const TagSearchCleared());
      emit(state.copyWith(
        displayState: DisplayState.options,
        error: () => null,
      ));
    });

    on<SearchGoToSuggestionsRequested>((event, emit) {
      tagSearchBloc
        ..add(const TagSearchSuggestionsCleared())
        ..add(const TagSearchCleared());

      searchHistorySuggestionsBloc
          .add(const sh.SearchHistorySuggestionsCleared());

      emit(state.copyWith(
        displayState: DisplayState.suggestion,
        error: () => null,
      ));
    });

    on<SearchSelectedTagCleared>((event, emit) {
      tagSearchBloc.add(const TagSearchSelectedTagCleared());
      add(const SearchGoBackToSearchOptionsRequested());
    });

    on<SearchSelectedTagRemoved>((event, emit) {
      tagSearchBloc.add(TagSearchSelectedTagRemoved(event.tag));

      // State hasn't been updated yet so don't check for empty
      if (state.selectedTags.length == 1) {
        add(const SearchGoBackToSearchOptionsRequested());
      }
    });

    on<_SearchRequested>((event, emit) async {
      searchHistoryBloc.add(sh.SearchHistoryAdded(event.query));

      onSearch(event.query);

      emit(state.copyWith(totalResults: () => -1));

      final tags = event.query.split(' ');
      if (booruType == BooruType.safebooru) {
        tags.add('rating:g');
      }

      final totalResults = await fetchPostCount(tags);

      emit(state.copyWith(totalResults: () => totalResults));
    });

    on<_CopyState>((event, emit) {
      // Related added
      if (state.displayState == DisplayState.result &&
          event.state.selectedTags != state.selectedTags) {
        add(const SearchRequested());
      }

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

    searchHistoryBloc.add(const sh.SearchHistoryFetched());

    onInit();
  }

  final compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }

  // ignore: no-empty-block
  void onSearch(String query) {}
  // ignore: no-empty-block
  void onInit() {}
  // ignore: no-empty-block
  void onBackToOptions() {}

  Future<int?> fetchPostCount(List<String> tags) async => null;
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
