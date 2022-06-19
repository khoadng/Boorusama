// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchState initial,
  }) : super(initial) {
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

    on<SearchQueryEmpty>((event, emit) {
      if (state.displayState == DisplayState.result) return;
      emit(state.copyWith(displayState: DisplayState.options));
    });
  }
}
