part of 'curated_bloc.dart';

@freezed
abstract class CuratedState with _$CuratedState {
  const factory CuratedState({
    @required List<Post> posts,
    @required int page,
    @required DateTime selectedTime,
    @required TimeScale selectedTimeScale,
    @required bool isRefreshing,
    @required bool isLoadingNew,
    @required bool isLoadingMore,
    @required @nullable Error error,
  }) = _CuratedState;

  factory CuratedState.initial() => CuratedState(
        posts: <Post>[],
        page: 1,
        selectedTime: DateTime.now(),
        selectedTimeScale: TimeScale.day,
        isRefreshing: false,
        isLoadingNew: false,
        isLoadingMore: false,
        error: null,
      );
}
