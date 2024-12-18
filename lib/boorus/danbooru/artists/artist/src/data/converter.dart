// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../urls/url.dart';
import '../types/artist.dart';

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
