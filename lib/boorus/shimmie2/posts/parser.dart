// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

Shimmie2Post postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  return Shimmie2Post(
    id: e.id ?? 0,
    thumbnailImageUrl: e.previewUrl ?? '',
    sampleImageUrl: e.fileUrl ?? '',
    originalImageUrl: e.fileUrl ?? '',
    tags: e.tags?.toSet() ?? {},
    rating: Rating.parse(e.rating),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.source),
    score: e.score ?? 0,
    duration: 0,
    fileSize: 0,
    format: extension(e.fileName ?? ''),
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.previewUrl ?? '',
    videoUrl: e.fileUrl ?? '',
    width: e.width?.toDouble() ?? 0,
    createdAt: e.date,
    uploaderId: null,
    uploaderName: e.author,
    metadata: metadata,
  );
}
