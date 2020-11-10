part of 'post_list_bloc.dart';

abstract class PostListEvent extends Equatable {
  const PostListEvent();

  @override
  List<Object> get props => [];
}

class ListLoadRequested extends PostListEvent {
  final List<Post> posts;

  ListLoadRequested(this.posts);

  @override
  List<Object> get props => [posts];
}

class MorePostLoaded extends PostListEvent {
  final List<Post> posts;

  MorePostLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}
