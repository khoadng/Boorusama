part of 'latest_state_notifier.dart';

@freezed
abstract class LatestState with _$LatestState {
  const factory LatestState.initial() = _Initial;
  const factory LatestState.loading() = _Loading;

  const factory LatestState.fetched({
    @required List<Post> posts,
  }) = _Fetched;
}
