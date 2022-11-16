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
    required TagSearchState tagSearchState,
    required this.metatags,
  }) : _tagSearchState = tagSearchState;

  final DisplayState displayState;
  final TagSearchState _tagSearchState;
  final List<Metatag> metatags;

  SearchState copyWith({
    DisplayState? displayState,
    TagSearchState? tagSearchState,
  }) =>
      SearchState(
        displayState: displayState ?? this.displayState,
        tagSearchState: tagSearchState ?? _tagSearchState,
        metatags: metatags,
      );

  @override
  List<Object> get props => [displayState, _tagSearchState];
}

extension SearchStateX on SearchState {
  String get currentQuery => _tagSearchState.query;
  List<TagSearchItem> get selectedTags => _tagSearchState.selectedTags;
  List<AutocompleteData> get suggestionTags => _tagSearchState.suggestionTags;
}
