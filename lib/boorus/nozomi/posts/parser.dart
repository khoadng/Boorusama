// Package imports:
import 'package:booru_clients/nozomi.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/local/types.dart';
import '../../../foundation/path.dart' as path;
import 'types.dart';

NozomiPost postDtoToPost(
  NozomiPostDto e,
  PostMetadata? metadata,
) {
  final media = e.primaryMedia;
  final mediaUrl = media?.mediaUrl ?? '';
  final isVideo = media?.isVideo ?? e.isVideo;
  final thumbnailUrl = media?.thumbnailUrl ?? '';
  final previewUrl = thumbnailUrl.isNotEmpty ? thumbnailUrl : mediaUrl;
  final sampleUrl = isVideo ? previewUrl : mediaUrl;
  final width = (media?.width ?? e.width)?.toDouble() ?? 0;
  final height = (media?.height ?? e.height)?.toDouble() ?? 0;
  final mediaAspectRatio = width <= 0 || height <= 0 ? null : width / height;
  final thumbnailAspectRatio = thumbnailUrl.isNotEmpty ? 1.0 : mediaAspectRatio;
  final sampleAspectRatio = isVideo ? thumbnailAspectRatio : mediaAspectRatio;

  return NozomiPost(
    id: e.id,
    thumbnailImageUrl: previewUrl,
    sampleImageUrl: sampleUrl,
    originalImageUrl: mediaUrl,
    tags: e.allTags,
    rating: Rating.unknown,
    hasComment: false,
    isTranslated: _hasTranslation(e.allTags),
    hasParentOrChildren: false,
    source: PostSource.none(),
    score: 0,
    duration: kNoduration,
    fileSize: 0,
    format: path.extension(mediaUrl),
    hasSound: isVideo ? null : false,
    height: height,
    md5: media?.dataId ?? e.dataId,
    videoThumbnailUrl: isVideo ? previewUrl : '',
    videoUrl: isVideo ? mediaUrl : '',
    width: width,
    uploaderId: null,
    uploaderName: null,
    createdAt: _parseNozomiDate(e.date),
    metadata: metadata,
    thumbnailMediaAspectRatio: thumbnailAspectRatio,
    sampleMediaAspectRatio: sampleAspectRatio,
    originalMediaAspectRatio: mediaAspectRatio,
    videoThumbnailMediaAspectRatio: isVideo ? thumbnailAspectRatio : null,
    videoMediaAspectRatio: isVideo ? mediaAspectRatio : null,
    artistTagSet: e.artistTags.map((e) => e.tag).toSet(),
    characterTagSet: e.characterTags.map((e) => e.tag).toSet(),
    copyrightTagSet: e.copyrightTags.map((e) => e.tag).toSet(),
  );
}

bool _hasTranslation(Set<String> tags) {
  return tags.contains('translated') && !tags.contains('hard_translated');
}

DateTime? _parseNozomiDate(String? value) {
  if (value == null || value.isEmpty) return null;

  final normalized = value
      .replaceFirst(' ', 'T')
      .replaceFirstMapped(
        RegExp(r'([+-]\d{2})$'),
        (match) => '${match.group(1)}:00',
      );

  return DateTime.tryParse(normalized);
}

Iterable<TagInfo> postDtoToTagInfos(
  NozomiPostDto post,
  String siteHost,
) sync* {
  yield* _tagInfos(
    post.generalTags,
    siteHost,
    TagCategory.general().name,
  );
  yield* _tagInfos(
    post.artistTags,
    siteHost,
    TagCategory.artist().name,
  );
  yield* _tagInfos(
    post.copyrightTags,
    siteHost,
    TagCategory.copyright().name,
  );
  yield* _tagInfos(
    post.characterTags,
    siteHost,
    TagCategory.character().name,
  );
}

Iterable<TagInfo> _tagInfos(
  Iterable<NozomiTagDto> tags,
  String siteHost,
  String category,
) sync* {
  for (final tag in tags) {
    if (tag.tag.isEmpty) continue;

    yield TagInfo(
      siteHost: siteHost,
      tagName: tag.tag,
      category: category,
    );
  }
}
