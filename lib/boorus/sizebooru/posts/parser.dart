// Package imports:
import 'package:booru_clients/sizebooru.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../foundation/path.dart' as path;
import 'types.dart';

SizebooruPost dtoToSizebooruPost(
  SizebooruPostDto dto,
  PostMetadata? metadata,
) {
  final fileUrl = dto.fileUrl ?? '';
  return SizebooruPost(
    id: dto.id,
    thumbnailImageUrl: dto.thumbnailUrl ?? '',
    sampleImageUrl: fileUrl,
    originalImageUrl: fileUrl,
    tags: dto.tags.map((e) => e.toLowerCase()).toSet(),
    rating: Rating.general,
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(dto.source),
    score: dto.score ?? 0,
    duration: 0,
    fileSize: 0,
    format: path.extension(dto.filename ?? fileUrl),
    hasSound: null,
    height: 0,
    md5: '',
    videoThumbnailUrl: '',
    videoUrl: '',
    width: 0,
    uploaderId: null,
    uploaderName: dto.uploader,
    createdAt: dto.createdAt,
    metadata: metadata,
  );
}
