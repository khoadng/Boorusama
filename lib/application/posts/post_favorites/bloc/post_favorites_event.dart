part of 'post_favorites_bloc.dart';

abstract class PostFavoritesEvent extends Equatable {
  const PostFavoritesEvent();

  @override
  List<Object> get props => [];
}

class GetFavoritePosts extends PostFavoritesEvent {
  final String username;
  final int page;

  GetFavoritePosts(this.username, this.page);
}
