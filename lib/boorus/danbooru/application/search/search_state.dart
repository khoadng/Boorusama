part of 'search_bloc.dart';

enum DisplayState {
  options,
  suggestion,
  loadingResult,
  result,
  noResult,
  error,
}

@immutable
class SearchState extends Equatable {
  const SearchState({
    required this.displayState,
  });

  final DisplayState displayState;

  SearchState copyWith({
    DisplayState? displayState,
  }) =>
      SearchState(
        displayState: displayState ?? this.displayState,
      );

  @override
  List<Object> get props => [displayState];
}
