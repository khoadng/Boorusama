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

class AddToFavorites extends PostFavoritesEvent {
  final int postId;

  AddToFavorites(this.postId);
}

class RemoveFromFavorites extends PostFavoritesEvent {
  final int postId;

  RemoveFromFavorites(this.postId);
}
