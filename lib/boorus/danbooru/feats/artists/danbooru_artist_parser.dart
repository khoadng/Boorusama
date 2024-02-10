// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'danbooru_artist.dart';
import 'danbooru_artist_url.dart';

DanbooruArtistUrl artistUrlDtoToArtistUrl(ArtistUrlDto dto) {
  return DanbooruArtistUrl(
    url: dto.url ?? "",
    isActive: dto.isActive ?? true,
  );
}

DanbooruArtist artistDtoToArtist(ArtistDto dto) {
  return DanbooruArtist(
    createdAt: dto.createdAt,
    id: dto.id,
    name: dto.name,
    groupName: dto.groupName,
    isBanned: dto.isBanned,
    isDeleted: dto.isDeleted,
    otherNames: List<String>.of(dto.otherNames),
    updatedAt: dto.updatedAt,
    urls: dto.urls?.map(artistUrlDtoToArtistUrl).toList() ?? [],
    postCount: dto.tag?.postCount,
  );
}
