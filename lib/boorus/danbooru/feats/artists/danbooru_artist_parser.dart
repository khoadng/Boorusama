// Package imports:
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/foundation/http/http.dart';
import 'danbooru_artist.dart';
import 'danbooru_artist_dto.dart';
import 'danbooru_artist_url.dart';
import 'danbooru_artist_url_dto.dart';

List<DanbooruArtist> parseArtist(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => DanbooruArtistDto.fromJson(item),
    ).map(artistDtoToArtist).toList();

List<DanbooruArtistUrl> parseArtistUrls(HttpResponse<dynamic> value) =>
    parseResponse(
      value: value,
      converter: (item) => DanbooruArtistUrlDto.fromJson(item),
    ).map(artistUrlDtoToArtistUrl).toList();

DanbooruArtistUrl artistUrlDtoToArtistUrl(DanbooruArtistUrlDto dto) {
  return DanbooruArtistUrl(
    url: dto.url ?? "",
    isActive: dto.isActive ?? true,
  );
}

DanbooruArtist artistDtoToArtist(DanbooruArtistDto dto) {
  return DanbooruArtist(
    createdAt: dto.createdAt,
    id: dto.id,
    name: dto.name,
    groupName: dto.groupName,
    isBanned: dto.isBanned,
    isDeleted: dto.isDeleted,
    otherNames: List<String>.of(dto.otherNames),
    updatedAt: dto.updatedAt,
    urls: dto.urls.map(artistUrlDtoToArtistUrl).toList(),
  );
}
