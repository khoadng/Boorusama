// Package imports:
import 'package:path/path.dart' as path;
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/gelbooru/domain/gelbooru_post.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/posts/post_repository.dart';
import 'package:boorusama/core/domain/posts/rating.dart';
import 'post_dto.dart';

List<Post> parsePost(HttpResponse<dynamic> value) {
  final dtos = <PostDto>[];
  for (final item in value.response.data['post']) {
    dtos.add(PostDto.fromJson(item));
  }

  return dtos.map((e) {
    return postDtoToPost(e);
  }).toList();
}

class GelbooruPostRepositoryApi implements PostRepository {
  const GelbooruPostRepositoryApi({
    required this.api,
  });

  final GelbooruApi api;

  @override
  Future<List<Post>> getPostsFromTags(
    String tags,
    int page, {
    int? limit,
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

Post postDtoToPost(PostDto dto) {
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
    hasComment: _boolFromString(dto.hasComments),
    hasParentOrChildren: _boolFromString(dto.hasChildren) ||
        (dto.parentId != null && dto.parentId != 0),
    fileSize: 0,
  );
}

bool _boolFromString(String? value) {
  if (value == null) return false;
  if (value == 'false') return false;
  if (value == 'true') return true;

  return false;
}
