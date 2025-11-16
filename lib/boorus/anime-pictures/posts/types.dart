// Project imports:
import '../../../core/posts/post/types.dart';

class AnimePicturesPost extends SimplePost {
  AnimePicturesPost({
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
    required super.status,
    required this.tagsCount,
  });

  final int tagsCount;
}

class AnimePicturesPostStatus implements PostStatus {
  AnimePicturesPostStatus._({
    required this.value,
    required this.type,
  });

  static AnimePicturesPostStatus? from({
    required int? value,
    required int? type,
  }) => switch ((value, type)) {
    (final v?, final t?) => AnimePicturesPostStatus._(
      value: v,
      type: t,
    ),
    _ => null,
  };

  final int value;
  final int type;

  @override
  bool matches(String status) {
    // AnimePictures uses numeric status, try to match by string representation
    return value.toString() == status;
  }
}
