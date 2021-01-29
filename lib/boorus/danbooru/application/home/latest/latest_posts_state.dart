part of 'latest_posts_state_notifier.dart';

@freezed
abstract class LatestPostsState with _$LatestPostsState {
  const factory LatestPostsState({
    @required ListState<Post> posts,
  }) = _LatestPostsState;

  factory LatestPostsState.initial() => LatestPostsState(
        posts: ListState.initial(),
      );
}
