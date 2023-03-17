import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/gelbooru/post_dto.dart';
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:retrofit/retrofit.dart';

import 'package:path/path.dart' as path;

import 'gelbooru_post.dart';

List<GelbooruPost> parsePost(HttpResponse<dynamic> value) {
  final dtos = <PostDto>[];
  for (final item in value.response.data['post']) {
    dtos.add(PostDto.fromJson(item));
  }

  return dtos.map((e) {
    return postDtoToPost(e);
  }).toList();
}

class GelbooruPostRepositoryApi {
  const GelbooruPostRepositoryApi({
    required this.api,
  });

  final GelbooruApi api;

  Future<List<GelbooruPost>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  }) {
    return api
        .getPosts(
          null,
          null,
          'dapi',
          'post',
          'index',
          tags,
          '1',
          (page - 1).toString(),
        )
        .then(parsePost);
  }
}

GelbooruPost postDtoToPost(PostDto dto) {
  return GelbooruPost(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: dto.tags?.split(' ').toList() ?? [],
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.image ?? 'foo.png').substring(1),
    source: dto.source,
    rating: mapStringToRating(dto.rating ?? 'general'),
    downloadUrl: dto.previewUrl ?? '',
    md5: dto.md5 ?? '',
    sampleLargeImageUrl: dto.sampleUrl ?? '',
    hasComment: _boolFromString(dto.hasComments),
    hasParentOrChildren: _boolFromString(dto.hasChildren) ||
        (dto.parentId != null && dto.parentId != 0),
  );
}

bool _boolFromString(String? value) {
  if (value == null) return false;
  if (value == 'false') return false;
  if (value == 'true') return true;

  return false;
}
