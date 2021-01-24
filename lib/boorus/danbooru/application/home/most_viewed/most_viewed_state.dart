part of 'most_viewed_state_notifier.dart';

@freezed
abstract class MostViewedState with _$MostViewedState {
  const factory MostViewedState({
    @required List<Post> posts,
    @required int page,
    @required DateTime selectedDate,
    @required TimeScale selectedTimeScale,
    @required PostState postsState,
  }) = _MostViewedState;

  factory MostViewedState.initial() => MostViewedState(
        posts: [],
        page: 1,
        selectedDate: DateTime.now(),
        selectedTimeScale: TimeScale.day,
        postsState: PostState.empty(),
      );
}
