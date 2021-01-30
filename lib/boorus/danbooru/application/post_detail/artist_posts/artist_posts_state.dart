part of 'artist_posts_state_notifier.dart';

@freezed
abstract class ArtistPostsState with _$ArtistPostsState {
  const factory ArtistPostsState.empty() = _Empty;
  const factory ArtistPostsState.loading() = _Loading;
  const factory ArtistPostsState.fetched({
    @required List<Post> posts,
  }) = _Fetched;
  const factory ArtistPostsState.error() = _Error;
}
