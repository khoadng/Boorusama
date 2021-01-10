part of 'popular_bloc.dart';

@freezed
abstract class PopularState with _$PopularState {
  const factory PopularState({
    @required List<Post> posts,
    @required int page,
    @required DateTime selectedTime,
    @required TimeScale selectedTimeScale,
    @required bool isRefreshing,
    @required bool isLoadingNew,
    @required bool isLoadingMore,
    @required @nullable Error error,
  }) = _PopularState;

  factory PopularState.initial() => PopularState(
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
