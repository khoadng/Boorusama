part of 'post_list_bloc.dart';

@immutable
abstract class PostListState extends Equatable {}

class PostListInitial extends PostListState {
  @override
  List<Object> get props => [];
}

class PostListLoading extends PostListState {
  @override
  List<Object> get props => [];
}

class PostListLoaded extends PostListState {
  final List<Post> posts;

  PostListLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class PostListError extends PostListState {
  final String message;

  PostListError(this.message);

  @override
  List<Object> get props => [message];
}
