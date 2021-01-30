part of 'artist_commentary_state_notifier.dart';

@freezed
abstract class ArtistCommentaryState with _$ArtistCommentaryState {
  const factory ArtistCommentaryState.initial() = _Initial;
  const factory ArtistCommentaryState.loading() = _Loading;
  const factory ArtistCommentaryState.fetched({
    @required ArtistCommentary artistCommentary,
  }) = _Fetched;
  const factory ArtistCommentaryState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
