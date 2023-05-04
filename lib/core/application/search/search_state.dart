part of 'search_bloc.dart';

enum DisplayState {
  options,
  suggestion,
  result,
}

@immutable
class SearchState extends Equatable {
  const SearchState({
    required this.displayState,
    required TagSearchState tagSearchState,
    required this.metatags,
    this.error,
  }) : _tagSearchState = tagSearchState;

  final DisplayState displayState;
  final TagSearchState _tagSearchState;
  final List<Metatag> metatags;
  final String? error;

  SearchState copyWith({
    DisplayState? displayState,
    TagSearchState? tagSearchState,
    String? Function()? error,
  }) =>
      SearchState(
        displayState: displayState ?? this.displayState,
        tagSearchState: tagSearchState ?? _tagSearchState,
        metatags: metatags,
        error: error != null ? error() : this.error,
      );

  @override
  List<Object?> get props => [
        displayState,
        _tagSearchState,
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
