part of 'post_search_bloc.dart';

abstract class PostSearchState extends Equatable {
  const PostSearchState();

  @override
  List<Object> get props => [];
}

class SearchIdle extends PostSearchState {
  @override
  String toString() => "SearchIdle";
}

class SearchLoading extends PostSearchState {
  @override
  String toString() => "SearchLoading";
}

class SearchSuccess extends PostSearchState {
  final List<Post> posts;
  final String query;
  final int page;

  SearchSuccess({
    @required this.posts,
    @required this.query,
    @required this.page,
  });

  @override
  String toString() => "SearchSuccess";

  @override
  List<Object> get props => [posts, query, page];
}

class SearchError extends PostSearchState {
  final String error;
  final String message;

  SearchError({
    @required this.error,
    @required this.message,
  });

  @override
  String toString() => "SearchError { error: $error, message: $message }";

  @override
  List<Object> get props => [error, message];
}
