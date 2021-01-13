part of 'popular_state_notifier.dart';

@freezed
abstract class PopularState with _$PopularState {
  const factory PopularState.initial() = _Initial;
  const factory PopularState.loading() = _Loading;
  const factory PopularState.fetched({
    @required List<PostViewModel> posts,
    @required int page,
    @required DateTime date,
    @required TimeScale scale,
  }) = _Fetched;
  const factory PopularState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
