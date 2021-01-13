part of 'most_viewed_state_notifier.dart';

@freezed
abstract class MostViewedState with _$MostViewedState {
  const factory MostViewedState.initial() = _Initial;
  const factory MostViewedState.loading() = _Loading;
  const factory MostViewedState.fetched({
    @required List<PostViewModel> posts,
    @required DateTime date,
  }) = _Fetched;
  const factory MostViewedState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
