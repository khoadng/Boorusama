part of 'post_favorites_bloc.dart';

@freezed
abstract class PostFavoritesEvent with _$PostFavoritesEvent {
  const factory PostFavoritesEvent.fetched({
    @required String username,
    @required int page,
  }) = _Fetched;

  const factory PostFavoritesEvent.added({@required int postId}) = _Added;
  const factory PostFavoritesEvent.removed({@required int postId}) = _Removed;
}
