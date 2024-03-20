// Package imports:
import 'package:path/path.dart' as path;

// Project imports:
import 'package:boorusama/clients/gelbooru/types/post_v2_dto.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'gelbooru_v2_post.dart';

GelbooruV2Post gelbooruV2PostDtoToGelbooruPost(PostV2Dto dto) {
  return GelbooruV2Post(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? dto.fileUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: dto.tags?.split(' ').toSet() ?? {},
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.fileUrl ?? 'foo.png').substring(1),
    source: PostSource.from(dto.source),
    rating: mapStringToRating(dto.rating ?? 'safe'),
    md5: dto.hash ?? '',
    hasComment: dto.commentCount != null && dto.commentCount! > 0,
    hasParentOrChildren: (dto.parentId != null && dto.parentId != 0),
    fileSize: 0,
    score: dto.score ?? 0,
    createdAt: null,
    parentId: dto.parentId != 0 ? dto.parentId : null,
    uploaderId: null,
    uploaderName: dto.owner,
  );
}
