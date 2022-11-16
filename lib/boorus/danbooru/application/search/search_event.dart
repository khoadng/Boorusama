part of 'search_bloc.dart';

@immutable
abstract class SearchEvent extends Equatable {
  const SearchEvent();
}

class SearchSuggestionReceived extends SearchEvent {
  const SearchSuggestionReceived();
  @override
  List<Object?> get props => [];
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
