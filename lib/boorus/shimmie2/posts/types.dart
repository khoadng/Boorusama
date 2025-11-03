// Project imports:
import '../../../core/posts/post/types.dart';

class Shimmie2Post extends SimplePost {
  Shimmie2Post({
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
    super.parentId,
    super.downvotes,
    this.locked,
    this.ext,
    this.mime,
    this.niceName,
    this.tooltip,
    this.favorites,
    this.numericScore,
    this.notes,
    this.hasChildren,
    this.title,
    this.approved,
    this.approvedById,
    this.private,
    this.trash,
    this.ownerJoinDate,
    this.votes,
    this.myVote,
  });

  final bool? locked;
  final String? ext;
  final String? mime;
  final String? niceName;
  final String? tooltip;
  final int? favorites;
  final int? numericScore;
  final int? notes;
  final bool? hasChildren;
  final String? title;
  final bool? approved;
  final int? approvedById;
  final bool? private;
  final bool? trash;
  final DateTime? ownerJoinDate;
  final int? votes;
  final int? myVote;
}
