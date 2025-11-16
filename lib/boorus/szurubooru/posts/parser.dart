// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:collection/collection.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/tag/types.dart';
import '../../../foundation/path.dart';
import 'types.dart';

SzurubooruPost postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
  List<TagCategory>? categories,
) {
  return SzurubooruPost(
    id: e.id ?? 0,
    thumbnailImageUrl: e.thumbnailUrl ?? '',
    sampleImageUrl: e.contentUrl ?? '',
    originalImageUrl: e.contentUrl ?? '',
    tags: e.tags?.map((e) => e.names?.firstOrNull).nonNulls.toSet() ?? {},
    tagDetails:
        e.tags
            ?.map(
              (e) => Tag(
                name: e.names?.firstOrNull ?? '???',
                category:
                    categories?.firstWhereOrNull(
                      (element) => element.name == e.category,
                    ) ??
                    TagCategory.general(),
                postCount: e.usages ?? 0,
              ),
            )
            .toList() ??
        [],
    rating: switch (e.safety?.toLowerCase()) {
      'safe' => Rating.general,
      'questionable' => Rating.questionable,
      'sketchy' => Rating.questionable,
      'unsafe' => Rating.explicit,
      _ => Rating.general,
    },
    hasComment: (e.commentCount ?? 0) > 0,
    isTranslated: (e.noteCount ?? 0) > 0,
    hasParentOrChildren: (e.relationCount ?? 0) > 0,
    source: PostSource.from(e.source),
    score: e.score ?? 0,
    duration: 0,
    fileSize: e.fileSize ?? 0,
    format: extension(e.contentUrl ?? ''),
    hasSound: e.flags?.contains('sound'),
    height: e.canvasHeight?.toDouble() ?? 0,
    md5: e.checksumMD5 ?? '',
    videoThumbnailUrl: e.thumbnailUrl ?? '',
    videoUrl: e.contentUrl ?? '',
    width: e.canvasWidth?.toDouble() ?? 0,
    createdAt: e.creationTime != null
        ? DateTime.tryParse(e.creationTime!)
        : null,
    uploaderName: e.user?.name,
    ownFavorite: e.ownFavorite ?? false,
    favoriteCount: e.favoriteCount ?? 0,
    commentCount: e.commentCount ?? 0,
    metadata: metadata,
    status: null,
  );
}
