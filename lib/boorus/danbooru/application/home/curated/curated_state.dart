part of 'curated_state_notifier.dart';

@freezed
abstract class CuratedState with _$CuratedState {
  const factory CuratedState({
    @required List<Post> posts,
    @required int page,
    @required DateTime selectedDate,
    @required TimeScale selectedTimeScale,
    @required PostState postsState,
  }) = _CuratedState;

  factory CuratedState.initial() => CuratedState(
        posts: [],
        page: 1,
        selectedDate: DateTime.now(),
        selectedTimeScale: TimeScale.day,
        postsState: PostState.empty(),
      );
}
