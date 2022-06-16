import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchState initial,
  }) : super(initial) {
    on<SearchSuggestionReceived>((event, emit) =>
        emit(state.copyWith(displayState: DisplayState.suggestion)));

    // on<SearchRequested>((event, emit) =>
    //     emit(state.copyWith(displayState: DisplayState.loadingResult)));

    on<SearchRequested>((event, emit) =>
        emit(state.copyWith(displayState: DisplayState.result)));

    // on<SearchCompleted>((event, emit) {
    //   emit(state.copyWith(displayState: DisplayState.result));
    // });

    // on<SearchNoData>((event, emit) {
    //   emit(state.copyWith(displayState: DisplayState.noResult));
    // });

    // on<SearchError>((event, emit) {
    //   emit(state.copyWith(displayState: DisplayState.error));
    // });

    on<SearchSelectedTagCleared>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.suggestion));
    });

    on<SearchQueryEmpty>((event, emit) {
      emit(state.copyWith(displayState: DisplayState.options));
    });
  }
}
