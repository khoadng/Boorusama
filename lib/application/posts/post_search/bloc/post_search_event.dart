part of 'post_search_bloc.dart';

abstract class PostSearchEvent extends Equatable {
  const PostSearchEvent();

  @override
  List<Object> get props => [];
}

class PostSearched extends PostSearchEvent {
  final String query;
  final int page;

  PostSearched({
    @required this.query,
    @required this.page,
  });

  @override
  String toString() => "PostSearched { query: $query, page: $page }";

  @override
  List<Object> get props => [query, page];
}
