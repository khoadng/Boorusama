part of 'post_favorites_bloc.dart';

@freezed
abstract class PostFavoritesState with _$PostFavoritesState {
  const factory PostFavoritesState.initial() = _Initial;
  const factory PostFavoritesState.loading() = _Loading;
  const factory PostFavoritesState.loaded({@required List<Post> posts}) =
      _Loaded;

  const factory PostFavoritesState.addCompleted() = _AddCompleted;
  const factory PostFavoritesState.removeComplated() = _RemoveComplated;
}
