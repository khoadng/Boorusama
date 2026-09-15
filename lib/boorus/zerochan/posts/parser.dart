// Package imports:
import 'package:booru_clients/zerochan.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../foundation/path.dart' as path;
import 'types.dart';

ZerochanPost postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  final mediaUrl = _firstNonEmptyUrl([
    e.full,
    e.large,
    e.medium,
    e.small,
    e.thumbnail,
  ]);

  return ZerochanPost(
    id: e.id ?? 0,
    thumbnailImageUrl: _firstNonEmptyUrl([e.thumbnail, e.medium, e.small]),
    sampleImageUrl: e.sampleUrl() ?? '',
    originalImageUrl: e.fileUrl() ?? '',
    tags: e.tags?.map((e) => e.toLowerCase()).toSet() ?? {},
    rating: Rating.general,
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.source),
    score: 0,
    duration: kNoduration,
    fileSize: e.size ?? 0,
    format: path.extension(mediaUrl),
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

String _firstNonEmptyUrl(Iterable<String?> urls) {
  for (final url in urls) {
    if (url case final url? when url.isNotEmpty) return url;
  }

  return '';
}
