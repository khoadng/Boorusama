// Package imports:
import 'package:booru_clients/hydrus.dart';

// Project imports:
import '../../../core/posts/post/post.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import 'types.dart';

HydrusPost postDtoToPost(FileDto file, PostMetadata? metadata) {
  return HydrusPost(
    id: file.fileId ?? 0,
    thumbnailImageUrl: file.thumbnailUrl,
    sampleImageUrl: file.imageUrl,
    originalImageUrl: file.imageUrl,
    tags: file.allTags,
    rating: Rating.general,
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(file.firstSource),
    score: 0,
    duration: file.duration?.toDouble() ?? 0,
    fileSize: file.size ?? 0,
    format: file.ext ?? '',
    hasSound: file.hasAudio,
    height: file.height?.toDouble() ?? 0,
    md5: file.hash ?? '',
    videoThumbnailUrl: file.thumbnailUrl,
    videoUrl: file.imageUrl,
    width: file.width?.toDouble() ?? 0,
    uploaderId: null,
    uploaderName: null,
    createdAt: null,
    metadata: metadata,
    ownFavorite: file.faved,
  );
}
