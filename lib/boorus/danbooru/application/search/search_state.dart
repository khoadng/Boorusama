part of 'search_bloc.dart';

enum DisplayState {
  options,
  suggestion,
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
    this.error,
    required this.totalResults,
  }) : _tagSearchState = tagSearchState;

  final DisplayState displayState;
  final TagSearchState _tagSearchState;
  final List<Metatag> metatags;
  final String? error;
  final int? totalResults;

  SearchState copyWith({
    DisplayState? displayState,
    TagSearchState? tagSearchState,
    String? Function()? error,
    int? Function()? totalResults,
  }) =>
      SearchState(
        displayState: displayState ?? this.displayState,
        tagSearchState: tagSearchState ?? _tagSearchState,
        metatags: metatags,
        error: error != null ? error() : this.error,
        totalResults: totalResults != null ? totalResults() : this.totalResults,
      );

  @override
  List<Object?> get props => [
        displayState,
        _tagSearchState,
        totalResults,
      ];
}

extension SearchStateX on SearchState {
  String get currentQuery => _tagSearchState.query;
  List<TagSearchItem> get selectedTags => _tagSearchState.selectedTags;
  List<AutocompleteData> get suggestionTags => _tagSearchState.suggestionTags;

  bool get hasSearchError => error != null;

  bool get allowSearch {
    if (displayState == DisplayState.options) {
      return selectedTags.isNotEmpty;
    }
    if (displayState == DisplayState.suggestion) return false;

    return false;
  }
}
