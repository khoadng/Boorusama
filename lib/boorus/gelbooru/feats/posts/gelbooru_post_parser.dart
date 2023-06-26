// Package imports:
import 'package:path/path.dart' as path;
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'gelbooru_post.dart';
import 'gelbooru_post_dto.dart';

List<GelbooruPost> parseGelbooruResponse(HttpResponse<dynamic> value) =>
    parseGelbooruDtos(value).map(gelbooruPostDtoToGelbooruPost).toList();

List<GelbooruPostDto> parseGelbooruDtos(HttpResponse<dynamic> value) {
  final dtos = <GelbooruPostDto>[];
  dynamic data;
  try {
    data = value.response.data['post'];
    if (data == null) return [];
  } catch (e) {
    return [];
  }

  for (final item in data) {
    dtos.add(GelbooruPostDto.fromJson(item));
  }

  return dtos;
}

GelbooruPost gelbooruPostDtoToGelbooruPost(GelbooruPostDto dto) {
  return GelbooruPost(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: dto.tags?.split(' ').toList() ?? [],
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.image ?? 'foo.png').substring(1),
    source: PostSource.from(dto.source),
    rating: mapStringToRating(dto.rating ?? 'general'),
    md5: dto.md5 ?? '',
    hasComment: _boolFromString(dto.hasComments),
    hasParentOrChildren: _boolFromString(dto.hasChildren) ||
        (dto.parentId != null && dto.parentId != 0),
    fileSize: 0,
    score: dto.score ?? 0,
    createdAt: dto.createdAt != null ? parseRFC822String(dto.createdAt!) : null,
  );
}

bool _boolFromString(String? value) {
  if (value == null) return false;
  if (value == 'false') return false;
  if (value == 'true') return true;

  return false;
}
