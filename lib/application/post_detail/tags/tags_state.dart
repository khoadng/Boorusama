part of 'tags_state_notifier.dart';

@freezed
abstract class TagsState with _$TagsState {
  const factory TagsState.initial() = _Initial;
  const factory TagsState.loading() = _Loading;
  const factory TagsState.fetched({
    @required List<Tag> tags,
  }) = _Fetched;
  const factory TagsState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
