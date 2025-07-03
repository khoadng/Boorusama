// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import '../../../core/downloads/urls/sanitizer.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/tags.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import 'types.dart';

GelbooruV1Post postDtoToPost(
  PostV1Dto post,
  PostMetadata? metadata,
) {
  return GelbooruV1Post(
    id: post.id ?? 0,
    thumbnailImageUrl: sanitizedUrl(post.previewUrl ?? ''),
    sampleImageUrl: sanitizedUrl(post.sampleUrl ?? ''),
    originalImageUrl: sanitizedUrl(post.fileUrl ?? ''),
    tags: post.tags.splitTagString(),
    rating: mapStringToRating(post.rating),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: post.score ?? 0,
    duration: 0,
    fileSize: 0,
    format: extension(post.fileUrl ?? ''),
    hasSound: null,
    height: 0,
    md5: post.md5 ?? '',
    videoThumbnailUrl: post.previewUrl ?? '',
    videoUrl: post.fileUrl ?? '',
    width: 0,
    uploaderId: null,
    createdAt: null,
    uploaderName: null,
    metadata: metadata,
  );
}
