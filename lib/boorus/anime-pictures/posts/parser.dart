// Package imports:
import 'package:booru_clients/anime_pictures.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

AnimePicturesPost dtoToAnimePicturesPost(
  PostDto e, {
  PostMetadata? metadata,
}) {
  return AnimePicturesPost(
    id: e.id ?? 0,
    thumbnailImageUrl: e.mediumPreview ?? '',
    sampleImageUrl: e.bigPreview ?? '',
    originalImageUrl: e.bigPreview ?? '',
    tags: const {},
    rating: switch (e.erotics) {
      EroticLevel.none => Rating.general,
      EroticLevel.light => Rating.sensitive,
      EroticLevel.moderate => Rating.questionable,
      EroticLevel.hard => Rating.explicit,
      null => Rating.unknown,
    },
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: e.scoreNumber ?? 0,
    duration: 0,
    fileSize: e.size ?? 0,
    format: e.ext ?? '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.smallPreview ?? '',
    videoUrl: e.bigPreview ?? '',
    width: e.width?.toDouble() ?? 0,
    createdAt: e.pubtime != null ? DateTime.tryParse(e.pubtime!) : null,
    uploaderId: null,
    uploaderName: null,
    metadata: metadata,
    tagsCount: e.tagsCount ?? 0,
    status: AnimePicturesPostStatus.from(
      value: e.status,
      type: e.statusType,
    ),
  );
}
