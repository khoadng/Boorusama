part of 'post_favorite_state_notifier.dart';

@freezed
abstract class PostFavoriteState with _$PostFavoriteState {
  const factory PostFavoriteState.initial() = _Initial;
  const factory PostFavoriteState.loading() = _Loading;
  const factory PostFavoriteState.success() = _Success;
  const factory PostFavoriteState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
