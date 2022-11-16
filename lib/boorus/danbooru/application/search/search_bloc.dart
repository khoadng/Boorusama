// Flutter imports:
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
  }) : super(SearchState(
          displayState: initial,
          tagSearchState: tagSearchBloc.state,
        )) {
    on<SearchQueryChanged>((event, emit) {
      if (event.query.isEmpty) {
        if (state.displayState != DisplayState.result) {
          emit(state.copyWith(displayState: DisplayState.options));
        }
      }

      tagSearchBloc.add(TagSearchChanged(event.query));
    });

    on<SearchTagSelected>((event, emit) {
      tagSearchBloc.add(TagSearchNewTagSelected(event.tag));
      emit(state.copyWith(displayState: DisplayState.options));
    });

    on<SearchSuggestionReceived>((event, emit) =>
        emit(state.copyWith(displayState: DisplayState.suggestion)));

    on<SearchRequested>((event, emit) =>
        emit(state.copyWith(displayState: DisplayState.result)));

    on<SearchGoBackToSearchOptionsRequested>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.options));
    });

    on<SearchSelectedTagCleared>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.options));
    });

    on<SearchNoData>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.noResult));
    });

    on<SearchError>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.error));
    });

    on<_CopyState>((event, emit) {
      emit(state.copyWith(tagSearchState: event.state));
    });

    tagSearchBloc.stream
        .pairwise()
        .where((event) => event.first.suggestionTags != event[1].suggestionTags)
        // .map((event) => event[1])
        .listen((event) => add(const SearchSuggestionReceived()))
        .addTo(compositeSubscription);

    tagSearchBloc.stream
        .distinct()
        .listen((event) => add(_CopyState(state: event)))
        .addTo(compositeSubscription);
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
