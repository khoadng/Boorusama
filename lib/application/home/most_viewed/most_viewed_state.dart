part of 'most_viewed_bloc.dart';

@freezed
abstract class MostViewedState with _$MostViewedState {
  const factory MostViewedState({
    @required List<Post> posts,
    @required DateTime selectedTime,
    @required bool isRefreshing,
    @required bool isLoadingNew,
    @required @nullable Error error,
  }) = _MostViewedState;

  factory MostViewedState.initial() => MostViewedState(
        posts: <Post>[],
        selectedTime: DateTime.now(),
        isRefreshing: false,
        isLoadingNew: false,
        error: null,
      );
}
