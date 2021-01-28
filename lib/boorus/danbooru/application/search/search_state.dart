part of 'search_state_notifier.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @required ListState<Post> posts,
    @required @nullable Post currentViewingPost,
    @required @nullable Post lastViewedPost,
  }) = _SearchState;

  factory SearchState.initial() => SearchState(
        posts: ListState.initial(),
        currentViewingPost: null,
        lastViewedPost: null,
      );
}
