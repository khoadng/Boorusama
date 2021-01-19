part of 'latest_posts_state_notifier.dart';

@freezed
abstract class LatestPostsState with _$LatestPostsState {
  const factory LatestPostsState({
    @required List<Post> posts,
    @required int page,
    @required bool isRefreshing,
    @required bool isLoadingMore,
    String query,
  }) = _LatestPostsState;

  factory LatestPostsState.initial() => LatestPostsState(
        posts: <Post>[],
        page: 1,
        isRefreshing: false,
        isLoadingMore: false,
        query: "",
      );
}
