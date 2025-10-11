// Project imports:
import '../../../core/posts/post/post.dart';

class EshuushuuPost extends SimplePost {
  EshuushuuPost({
    required super.id,
    required super.thumbnailImageUrl,
    required super.sampleImageUrl,
    required super.originalImageUrl,
    required super.tags,
    required super.rating,
    required super.hasComment,
    required super.isTranslated,
    required super.hasParentOrChildren,
    required super.source,
    required super.score,
    required super.duration,
    required super.fileSize,
    required super.format,
    required super.hasSound,
    required super.height,
    required super.md5,
    required super.videoThumbnailUrl,
    required super.videoUrl,
    required super.width,
    required super.uploaderId,
    required super.createdAt,
    required super.uploaderName,
    required super.metadata,
    required this.characters,
    required this.artist,
    required this.sourceTags,
    required this.generalTags,
  });

  final Set<String>? characters;
  final Set<String>? artist;
  final Set<String>? sourceTags;
  final Set<String>? generalTags;
}
