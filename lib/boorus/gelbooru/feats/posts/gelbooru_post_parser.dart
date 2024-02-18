// Package imports:
import 'package:path/path.dart' as path;

// Project imports:
import 'package:boorusama/clients/gelbooru/types/types.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/time.dart';
import 'gelbooru_post.dart';

GelbooruPost gelbooruPostDtoToGelbooruPost(PostDto dto) {
  return GelbooruPost(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? dto.fileUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: dto.tags?.split(' ').toList() ?? [],
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.fileUrl ?? 'foo.png').substring(1),
    source: PostSource.from(dto.source),
    rating: mapStringToRating(dto.rating ?? 'general'),
    md5: dto.md5 ?? '',
    hasComment: dto.hasComments ?? false,
    hasParentOrChildren:
        dto.hasChildren ?? false || (dto.parentId != null && dto.parentId != 0),
    fileSize: 0,
    score: dto.score ?? 0,
    createdAt: dto.createdAt != null ? parseRFC822String(dto.createdAt!) : null,
    parentId: dto.parentId != 0 ? dto.parentId : null,
    uploaderId: dto.creatorId,
    uploaderName: dto.owner,
  );
}
