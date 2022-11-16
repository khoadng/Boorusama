// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/search/tag_search_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchState initial,
    required TagSearchBloc tagSearchBloc,
  }) : super(initial) {
    on<SearchQueryChanged>((event, emit) {
      if (event.query.isEmpty) {
        if (state.displayState != DisplayState.result) {
          emit(state.copyWith(displayState: DisplayState.options));
        }
      }

      tagSearchBloc.add(TagSearchChanged(event.query));
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
  }
}
