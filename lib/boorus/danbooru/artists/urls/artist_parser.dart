// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import 'artist_url.dart';

DanbooruArtistUrl artistUrlDtoToArtistUrl(ArtistUrlDto dto) {
  return DanbooruArtistUrl(
    url: dto.url ?? '',
    isActive: dto.isActive ?? true,
  );
}
