// Package imports:
import 'package:booru_clients/zerochan.dart';

// Project imports:
import '../../../core/foundation/path.dart' as path;
import '../../../core/posts/post/post.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import 'types.dart';

ZerochanPost postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  return ZerochanPost(
    id: e.id ?? 0,
    thumbnailImageUrl: e.thumbnail ?? '',
    sampleImageUrl: e.sampleUrl() ?? '',
    originalImageUrl: e.fileUrl() ?? '',
    tags: e.tags?.map((e) => e.toLowerCase()).toSet() ?? {},
    rating: Rating.general,
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.source),
    score: 0,
    duration: 0,
    fileSize: 0,
    format: path.extension(e.thumbnail ?? ''),
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: '',
    videoUrl: '',
    width: e.width?.toDouble() ?? 0,
    uploaderId: null,
    uploaderName: null,
    createdAt: null,
    metadata: metadata,
  );
}
