// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../../../core/artists/artists.dart';

ArtistCommentary artistCommentaryDtoToArtistCommentary(
  ArtistCommentaryDto? d,
) {
  if (d == null) {
    return const ArtistCommentary.empty();
  }

  return ArtistCommentary(
    originalTitle: d.originalTitle ?? '',
    originalDescription: d.originalDescription ?? '',
    translatedTitle: d.translatedTitle ?? '',
    translatedDescription: d.translatedDescription ?? '',
  );
}
