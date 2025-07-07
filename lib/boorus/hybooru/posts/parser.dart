// Package imports:
import 'package:booru_clients/hybooru.dart';

// Project imports:
import '../../../core/posts/post/post.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import 'types.dart';

HybooruPost postSummaryToPost(
  PostSummaryDto e,
  PostMetadata? metadata,
  String baseUrl,
) {
  return HybooruPost(
    id: e.id ?? 0,
    thumbnailImageUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    sampleImageUrl: _buildFileUrl(e, baseUrl),
    originalImageUrl: _buildFileUrl(e, baseUrl),
    tags: const {}, // PostSummary doesn't include tags
    rating: Rating.general, // No rating in summary
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: 0,
    duration: 0,
    fileSize: 0,
    format: e.extension ?? '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? e.sha256 ?? e.hash ?? '',
    videoThumbnailUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    videoUrl: _buildFileUrl(e, baseUrl),
    width: e.width?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(e.posted ?? ''),
    uploaderId: null,
    uploaderName: null,
    metadata: metadata,
  );
}

HybooruPost postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
  String baseUrl,
) {
  return HybooruPost(
    id: e.id ?? 0,
    thumbnailImageUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    sampleImageUrl: _buildFileUrl(e, baseUrl),
    originalImageUrl: _buildFileUrl(e, baseUrl),
    tags: e.tags?.keys.toSet() ?? {},
    rating: _mapRating(e.rating),
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: e.relations?.isNotEmpty == true,
    source: PostSource.from(e.sources?.firstOrNull),
    score: 0,
    duration: e.duration?.toDouble() ?? 0,
    fileSize: e.size ?? 0,
    format: e.extension ?? '',
    hasSound: e.hasAudio,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? e.sha256 ?? e.hash ?? '',
    videoThumbnailUrl: _buildFileUrl(e, baseUrl, thumbnail: true),
    videoUrl: _buildFileUrl(e, baseUrl),
    width: e.width?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(e.posted ?? ''),
    uploaderId: null,
    uploaderName: null,
    metadata: metadata,
  );
}

String _buildFileUrl(dynamic post, String baseUrl, {bool thumbnail = false}) {
  final hash = post is PostDto
      ? (post.sha256 ?? post.hash)
      : post is PostSummaryDto
      ? (post.sha256 ?? post.hash)
      : null;
  final extension = post is PostDto
      ? post.extension
      : post is PostSummaryDto
      ? post.extension
      : null;

  if (hash == null) return '';

  // Remove trailing slash from baseUrl if present
  final cleanBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  if (thumbnail) {
    return '$cleanBaseUrl/files/t$hash.thumbnail';
  } else {
    return '$cleanBaseUrl/files/f$hash${extension ?? ''}';
  }
}

Rating _mapRating(double? rating) {
  if (rating == null) return Rating.general;

  // Map 0-1 rating to our enum
  if (rating >= 0.8) return Rating.explicit;
  if (rating >= 0.4) return Rating.questionable;
  return Rating.general;
}
