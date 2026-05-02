// Project imports:
import '../../../core/posts/post/types.dart';

class NozomiPost extends SimplePost implements PostMediaAspectRatios {
  NozomiPost({
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
    required this.thumbnailMediaAspectRatio,
    required this.sampleMediaAspectRatio,
    required this.originalMediaAspectRatio,
    required this.videoThumbnailMediaAspectRatio,
    required this.videoMediaAspectRatio,
    required this.artistTagSet,
    required this.characterTagSet,
    required this.copyrightTagSet,
  });

  final Set<String> artistTagSet;
  final Set<String> characterTagSet;
  final Set<String> copyrightTagSet;

  final double? thumbnailMediaAspectRatio;
  final double? sampleMediaAspectRatio;
  final double? originalMediaAspectRatio;
  final double? videoThumbnailMediaAspectRatio;
  final double? videoMediaAspectRatio;

  @override
  double? get thumbnailAspectRatio => thumbnailMediaAspectRatio;

  @override
  double? get sampleAspectRatio => sampleMediaAspectRatio;

  @override
  double? get originalAspectRatio => originalMediaAspectRatio;

  @override
  double? get videoThumbnailAspectRatio => videoThumbnailMediaAspectRatio;

  @override
  double? get videoAspectRatio => videoMediaAspectRatio;

  @override
  Set<String>? get artistTags => artistTagSet;

  @override
  Set<String>? get characterTags => characterTagSet;

  @override
  Set<String>? get copyrightTags => copyrightTagSet;
}
