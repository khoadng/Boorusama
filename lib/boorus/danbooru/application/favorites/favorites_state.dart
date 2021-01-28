part of 'favorites_state_notifier.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @required ListState<Post> posts,
    @required @nullable Post currentViewingPost,
    @required @nullable Post lastViewedPost,
  }) = _FavoritesState;

  factory FavoritesState.initial() => FavoritesState(
        posts: ListState.initial(),
        currentViewingPost: null,
        lastViewedPost: null,
      );
}
