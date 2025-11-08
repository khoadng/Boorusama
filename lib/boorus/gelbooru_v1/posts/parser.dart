// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:coreutils/coreutils.dart';

// Project imports:
import '../../../core/posts/post/tags.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

GelbooruV1Post postDtoToPost(
  PostV1Dto post,
  PostMetadata? metadata,
) {
  return GelbooruV1Post(
    id: post.id ?? 0,
    thumbnailImageUrl: normalizeUrl(post.previewUrl),
    sampleImageUrl: normalizeUrl(post.sampleUrl),
    originalImageUrl: normalizeUrl(post.fileUrl),
    tags: post.tags.splitTagString(),
    rating: Rating.parse(post.rating),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: post.score ?? 0,
    duration: 0,
    fileSize: 0,
    format: urlExtension(post.fileUrl),
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
