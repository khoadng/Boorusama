// Package imports:
import 'package:booru_clients/eshuushuu.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../foundation/path.dart' as path;
import 'types.dart';

EshuushuuPost postDtoToPost(
  PostDto e,
  PostMetadata? metadata,
) {
  final artists = e.artist?.map(_normalizeTag).toSet();
  final characters = e.characters?.map(_normalizeTag).toSet();
  final sourceTags = e.source?.map(_normalizeTag).toSet();
  final generalTags = e.tags?.map(_normalizeTag).toSet();
  final allTags = {
    ...?artists,
    ...?characters,
    ...?sourceTags,
    ...?generalTags,
  };

  return EshuushuuPost(
    id: e.id ?? 0,
    thumbnailImageUrl: e.thumbnailUrl ?? '',
    sampleImageUrl: e.thumbnailUrl ?? '',
    originalImageUrl: e.imageUrl ?? '',
    tags: allTags,
    rating: Rating.general,
    hasComment: false,
    isTranslated: false,
    hasParentOrChildren: false,
    source: PostSource.from(e.source?.join(', ')),
    score: 0,
    duration: 0,
    fileSize: _parseFileSizeToBytes(e.fileSize),
    format: path.extension(e.filename ?? ''),
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: '',
    videoThumbnailUrl: '',
    videoUrl: '',
    width: e.width?.toDouble() ?? 0,
    uploaderId: null,
    uploaderName: e.submittedBy,
    createdAt: e.submittedOn,
    metadata: metadata,
    characters: characters,
    artist: artists,
    sourceTags: sourceTags,
    generalTags: generalTags,
  );
}

String _normalizeTag(String tag) {
  return tag.toLowerCase().replaceAll('_', ' ').trim();
}

int _parseFileSizeToBytes(String? fileSizeString) {
  if (fileSizeString == null || fileSizeString.isEmpty) return 0;

  final match = RegExp(r'([\d.]+)\s*(\w+)').firstMatch(fileSizeString);
  if (match == null) return 0;

  final value = double.tryParse(match.group(1) ?? '') ?? 0;
  final unit = match.group(2)?.toLowerCase() ?? '';

  return switch (unit) {
    'b' || 'bytes' => value.toInt(),
    'kb' || 'kilobytes' => (value * 1024).toInt(),
    'mb' || 'megabytes' => (value * 1024 * 1024).toInt(),
    'gb' || 'gigabytes' => (value * 1024 * 1024 * 1024).toInt(),
    'tb' || 'terabytes' => (value * 1024 * 1024 * 1024 * 1024).toInt(),
    _ => value.toInt(),
  };
}
