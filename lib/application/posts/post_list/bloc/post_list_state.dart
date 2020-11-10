part of 'post_list_bloc.dart';

@immutable
abstract class PostListState extends Equatable {}

class PostListEmpty extends PostListState {
  @override
  List<Object> get props => [];
}

class PostListLoaded extends PostListState {
  final List<Post> posts;

  PostListLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class AddtionalPostListLoaded extends PostListState {
  final List<Post> posts;

  AddtionalPostListLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

class PostListError extends PostListState {
  final String message;
  final String title;

  PostListError(this.message, this.title);

  @override
  List<Object> get props => [message, title];
}
