part of 'latest_posts_state_notifier.dart';

@freezed
abstract class LatestPostsState with _$LatestPostsState {
  const factory LatestPostsState({
    @required List<Post> posts,
    @required int page,
    @required @nullable Post currentViewingPost,
    @required @nullable Post lastViewedPost,
    @required PostState postsState,
  }) = _LatestPostsState;

  factory LatestPostsState.initial() => LatestPostsState(
        posts: <Post>[],
        page: 1,
        currentViewingPost: null,
        lastViewedPost: null,
        postsState: PostState.empty(),
      );
}
