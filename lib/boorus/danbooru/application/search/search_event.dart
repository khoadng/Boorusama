part of 'search_bloc.dart';

@immutable
abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchSelectedTagCleared extends SearchEvent {
  const SearchSelectedTagCleared();
  @override
  List<Object?> get props => [];
}

class SearchRequested extends SearchEvent {
  const SearchRequested();

  @override
  List<Object?> get props => [];
}

class SearchWithRawTagRequested extends SearchEvent {
  const SearchWithRawTagRequested(this.tag);

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class SearchNoData extends SearchEvent {
  const SearchNoData();
  @override
  List<Object?> get props => [];
}

class SearchError extends SearchEvent {
  const SearchError();
  @override
  List<Object?> get props => [];
}

class SearchGoBackToSearchOptionsRequested extends SearchEvent {
  const SearchGoBackToSearchOptionsRequested();
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged({
    required this.query,
  });

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchTagSelected extends SearchEvent {
  const SearchTagSelected({
    required this.tag,
  });

  final AutocompleteData tag;

  @override
  List<Object?> get props => [tag];
}

class SearchHistoryTagSelected extends SearchEvent {
  const SearchHistoryTagSelected({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class SearchHistoryDeleted extends SearchEvent {
  const SearchHistoryDeleted({
    required this.history,
  });

  final SearchHistory history;

  @override
  List<Object?> get props => [history];
}

class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();

  @override
  List<Object?> get props => [];
}
