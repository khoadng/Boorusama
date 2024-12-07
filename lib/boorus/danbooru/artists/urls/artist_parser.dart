// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'artist_url.dart';

DanbooruArtistUrl artistUrlDtoToArtistUrl(ArtistUrlDto dto) {
  return DanbooruArtistUrl(
    url: dto.url ?? '',
    isActive: dto.isActive ?? true,
  );
}
