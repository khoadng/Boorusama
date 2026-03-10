// Package imports:
import 'package:booru_clients/eshuushuu.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import 'types.dart';

EshuushuuPost postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  final artists = <String>{};
  final characters = <String>{};
  final sourceTags = <String>{};
  final generalTags = <String>{};

  if (e.tags != null) {
    for (final tag in e.tags!) {
      final title = tag.title;
      if (title == null) continue;
      final normalized = _normalizeTag(title);

      switch (tag.type) {
        case 2:
          sourceTags.add(normalized);
        case 3:
          artists.add(normalized);
        case 4:
          characters.add(normalized);
        default:
          generalTags.add(normalized);
      }
    }
  }

  final allTags = {
    ...artists,
    ...characters,
    ...sourceTags,
    ...generalTags,
  };

  final sampleUrl = e.mediumUrl ?? e.thumbnailUrl ?? '';
  final hasComments = (e.posts ?? 0) > 0;

  return EshuushuuPost(
    id: e.imageId ?? 0,
    thumbnailImageUrl: e.thumbnailUrl ?? '',
    sampleImageUrl: sampleUrl,
    originalImageUrl: e.url ?? '',
    tags: allTags,
    rating: Rating.general,
    hasComment: hasComments,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(
      sourceTags.isNotEmpty ? sourceTags.join(', ') : null,
    ),
    score: e.favorites ?? 0,
    duration: 0,
    fileSize: e.filesize ?? 0,
    format: e.ext ?? '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5Hash ?? '',
    videoThumbnailUrl: '',
    videoUrl: '',
    width: e.width?.toDouble() ?? 0,
    uploaderId: e.userId,
    uploaderName: e.username,
    createdAt: e.dateAdded,
    metadata: metadata,
    characters: characters.isNotEmpty ? characters : null,
    artist: artists.isNotEmpty ? artists : null,
    sourceTags: sourceTags.isNotEmpty ? sourceTags : null,
    generalTags: generalTags.isNotEmpty ? generalTags : null,
    largeImageUrl: e.largeUrl,
    isFavorited: e.isFavorited,
    favorites: e.favorites,
    bayesianRating: e.bayesianRating,
  );
}

String _normalizeTag(String tag) {
  return tag.toLowerCase().replaceAll('_', ' ').trim();
}
