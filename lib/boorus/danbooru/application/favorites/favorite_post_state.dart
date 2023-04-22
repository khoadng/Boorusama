part of 'favorite_post_cubit.dart';

@immutable
abstract class FavoritePostState extends Equatable {
  const FavoritePostState();

  @override
  List<Object> get props => [];
}

class FavoritePostInitial extends FavoritePostState {}

class FavoritePostLoading extends FavoritePostState {}

class FavoritePostListSuccess extends FavoritePostState {
  final Map<int, bool> favorites;

  const FavoritePostListSuccess({required this.favorites});

  @override
  List<Object> get props => [favorites];
}

class FavoritePostFailure extends FavoritePostState {}

class FavoritePostError extends FavoritePostState {
  final String message;

  const FavoritePostError(this.message);

  @override
  List<Object> get props => [message];
}
