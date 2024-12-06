// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';
import 'media_info_mixin.dart';
import 'rating.dart';
import 'sources/source.dart';
import 'translatable_mixin.dart';

class PostMetadata extends Equatable {
  const PostMetadata({
    this.page,
    this.search,
  });
  final int? page;
  final String? search;

  @override
  List<Object?> get props => [page, search];
}

abstract class Post
    with MediaInfoMixin, ImageInfoMixin, VideoInfoMixin, TagListCheckMixin
    implements TagDetails {
  int get id;
  DateTime? get createdAt;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  @override
  Set<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  int? get parentId;
  PostSource get source;
  int get score;
  int? get downvotes;
  int? get uploaderId;

  PostMetadata? get metadata;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}

abstract class SimplePost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin,
        TagListCheckMixin
    implements Post {
  SimplePost({
    required this.id,
    this.createdAt,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    this.parentId,
    required this.source,
    required this.score,
    this.downvotes,
    required this.duration,
    required this.fileSize,
    required this.format,
    required this.hasSound,
    required this.height,
    required this.md5,
    required this.videoThumbnailUrl,
    required this.videoUrl,
    required this.width,
    required this.uploaderId,
    this.uploaderName,
    required this.metadata,
  });

  @override
  final int id;
  @override
  final DateTime? createdAt;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final Set<String> tags;
  @override
  final Rating rating;
  @override
  final bool hasComment;
  @override
  final bool isTranslated;
  @override
  final bool hasParentOrChildren;
  @override
  final int? parentId;
  @override
  final PostSource source;
  @override
  final int score;
  @override
  final int? downvotes;
  @override
  final double duration;
  @override
  final int fileSize;
  @override
  final String format;
  @override
  final bool? hasSound;
  @override
  final double height;
  @override
  final String md5;
  @override
  final String videoThumbnailUrl;
  @override
  final String videoUrl;
  @override
  final double width;

  @override
  final int? uploaderId;

  final String? uploaderName;

  @override
  String getLink(String baseUrl);

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  final PostMetadata? metadata;

  @override
  List<Object?> get props => [id];
}

extension PostImageX on Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

  bool get hasNoImage =>
      thumbnailImageUrl.isEmpty &&
      sampleImageUrl.isEmpty &&
      originalImageUrl.isEmpty;

  bool get hasParent => parentId != null && parentId! > 0;
}

abstract interface class TagDetails {
  Set<String>? get artistTags;
  Set<String>? get characterTags;
  Set<String>? get copyrightTags;
}

mixin NoTagDetailsMixin implements Post {
  @override
  Set<String>? get artistTags => null;
  @override
  Set<String>? get characterTags => null;
  @override
  Set<String>? get copyrightTags => null;
}

extension PostX on Post {
  String get relationshipQuery => hasParent ? 'parent:$parentId' : 'parent:$id';
}

mixin TagListCheckMixin {
  Set<String> get tags;

  bool get isAI => tags.any((e) => _kAiTags.contains(e.toLowerCase()));
}

const _kAiTags = {
  'ai-generated',
  'ai_generated',
  'ai-created',
  'ai art',
};
