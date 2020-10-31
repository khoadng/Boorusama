part of 'post_favorites_bloc.dart';

abstract class PostFavoritesState extends Equatable {
  const PostFavoritesState();

  @override
  List<Object> get props => [];
}

class PostFavoritesInitial extends PostFavoritesState {}

class PostFavoritesLoading extends PostFavoritesState {}

class PostFavoritesLoaded extends PostFavoritesState {
  final List<Post> posts;

  PostFavoritesLoaded(this.posts);
}

class AddPostToFavoritesCompleted extends PostFavoritesState {}

class RemovePostToFavoritesCompleted extends PostFavoritesState {}
