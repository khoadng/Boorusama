part of 'curated_state_notifier.dart';

@freezed
abstract class CuratedState with _$CuratedState {
  const factory CuratedState.initial() = _Initial;
  const factory CuratedState.loading() = _Loading;
  const factory CuratedState.fetched({
    @required List<Post> posts,
  }) = _Fetched;
  const factory CuratedState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
