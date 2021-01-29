part of 'favorites_state_notifier.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @required ListState<Post> posts,
  }) = _FavoritesState;

  factory FavoritesState.initial() => FavoritesState(
        posts: ListState.initial(),
      );
}
