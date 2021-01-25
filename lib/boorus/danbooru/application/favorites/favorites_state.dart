part of 'favorites_state_notifier.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @required List<Post> posts,
    @required int page,
    @required PostState postsState,
  }) = _FavoritesState;

  factory FavoritesState.initial() => FavoritesState(
        posts: [],
        page: 1,
        postsState: PostState.empty(),
      );
}
