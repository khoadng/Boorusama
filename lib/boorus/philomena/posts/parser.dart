// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

PhilomenaPost postDtoToPost(ImageDto e, PostMetadata? metadata) {
  final isVideo = e.mimeType?.contains('video') ?? false;

  return PhilomenaPost(
    id: e.id ?? 0,
    thumbnailImageUrl: isVideo
        ? _parseVideoThumbnail(e) ?? ''
        : e.representations?.thumb ?? '',
    sampleImageUrl: e.representations?.medium ?? '',
    originalImageUrl: e.representations?.full ?? '',
    tags: e.tags?.map((e) => e.replaceAll('+', '_')).toSet() ?? {},
    rating: Rating.general,
    commentCount: e.commentCount ?? 0,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.sourceUrl),
    score: e.score ?? 0,
    duration: e.duration ?? 0,
    fileSize: e.size ?? 0,
    format: e.format ?? '',
    hasSound: e.tags?.contains('sound'),
    height: e.height?.toDouble() ?? 0,
    md5: e.sha512Hash ?? '',
    videoThumbnailUrl: isVideo ? _parseVideoThumbnail(e) ?? '' : '',
    videoUrl: e.representations?.full ?? '',
    width: e.width?.toDouble() ?? 0,
    description: e.description ?? '',
    createdAt: e.createdAt,
    favCount: e.faves ?? 0,
    upvotes: e.upvotes ?? 0,
    downvotes: e.downvotes ?? 0,
    representation: PhilomenaRepresentation(
      full: e.representations?.full ?? '',
      large: e.representations?.large ?? '',
      medium: e.representations?.medium ?? '',
      small: e.representations?.small ?? '',
      tall: e.representations?.tall ?? '',
      thumb: e.representations?.thumb ?? '',
      thumbSmall: e.representations?.thumbSmall ?? '',
      thumbTiny: e.representations?.thumbTiny ?? '',
    ),
    uploaderId: e.uploaderId,
    uploaderName: e.uploader,
    metadata: metadata,
    status: null,
  );
}

String? _parseVideoThumbnail(ImageDto e) =>
    e.representations?.thumb.toOption().fold(
      () => '',
      (url) => '${url.substring(0, url.lastIndexOf("/") + 1)}thumb.gif',
    );
