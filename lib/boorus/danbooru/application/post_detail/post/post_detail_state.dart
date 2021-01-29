part of 'post_detail_state_notifier.dart';

@freezed
abstract class PostDetailState with _$PostDetailState {
  const factory PostDetailState.initial() = _Initial;
  const factory PostDetailState.loading() = _Loading;
  const factory PostDetailState.fetched({@required PostDetail details}) =
      _Fetched;
  const factory PostDetailState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
