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

class SearchQueryEmpty extends SearchEvent {
  const SearchQueryEmpty();
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

class SearchCompleted extends SearchEvent {
  const SearchCompleted();
  @override
  List<Object?> get props => [];
}
