// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';

class MoebooruPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin
    implements Post {
  MoebooruPost({
    required this.id,
    required this.tags,
    required this.source,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.largeImageUrl,
    required this.originalImageUrl,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    required this.format,
    required this.width,
    required this.height,
    required this.md5,
    required this.fileSize,
    required this.score,
    required this.createdAt,
    required this.parentId,
    required this.uploaderId,
    required this.uploaderName,
    required this.metadata,
    required this.status,
  });

  @override
  final int id;
  @override
  final Set<String> tags;
  @override
  final PostSource source;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  final String largeImageUrl;
  @override
  final String originalImageUrl;
  @override
  final Rating rating;
  @override
  final bool hasComment;
  @override
  final bool isTranslated;
  @override
  final bool hasParentOrChildren;

  @override
  final String format;
  @override
  final double width;
  @override
  final double height;
  @override
  final String md5;
  @override
  final int fileSize;
  @override
  final int score;

  @override
  List<Object?> get props => [id];

  @override
  double get duration => -1;

  @override
  final DateTime? createdAt;

  @override
  bool? get hasSound => null;
  @override
  String get videoUrl => originalImageUrl;
  @override
  String get videoThumbnailUrl => thumbnailImageUrl;
  @override
  int? get downvotes => null;
  @override
  final int? parentId;
  @override
  final int? uploaderId;

  @override
  final String? uploaderName;

  @override
  final PostMetadata? metadata;

  @override
  final PostStatus? status;
}
