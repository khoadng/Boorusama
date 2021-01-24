part of 'popular_state_notifier.dart';

@freezed
abstract class PopularState with _$PopularState {
  const factory PopularState({
    @required List<Post> posts,
    @required int page,
    @required DateTime selectedDate,
    @required TimeScale selectedTimeScale,
    @required PostState postsState,
  }) = _PopularState;

  factory PopularState.initial() => PopularState(
        posts: [],
        page: 1,
        selectedDate: DateTime.now(),
        selectedTimeScale: TimeScale.day,
        postsState: PostState.empty(),
      );
}
