// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:foundation/foundation.dart';
import 'package:path/path.dart' as path;

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../common/parser.dart';
import 'types.dart';

GelbooruPost gelbooruPostDtoToGelbooruPostNoMetadata(PostDto dto) =>
    gelbooruPostDtoToGelbooruPost(dto, null);

GelbooruPost gelbooruPostDtoToGelbooruPost(
  PostDto dto,
  PostMetadata? metadata,
) {
  final decodedTags =
      dto.tags?.split(' ').map(decodeHtmlEntities).toSet() ?? {};

  return GelbooruPost(
    id: dto.id!,
    thumbnailImageUrl: dto.previewUrl ?? '',
    sampleImageUrl: dto.sampleUrl ?? dto.fileUrl ?? '',
    originalImageUrl: dto.fileUrl ?? '',
    tags: decodedTags,
    width: dto.width?.toDouble() ?? 0,
    height: dto.height?.toDouble() ?? 0,
    format: path.extension(dto.fileUrl ?? 'foo.png').substring(1),
    source: PostSource.from(dto.source),
    rating: Rating.parse(dto.rating ?? 'general'),
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
    metadata: metadata,
    status: StringPostStatus.tryParse(dto.status),
  );
}
