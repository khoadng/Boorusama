// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../core/posts/post/post.dart';
import '../../core/posts/rating/rating.dart';
import '../../core/posts/sources/source.dart';
import '../../core/tags/tag/tag.dart';

class SzurubooruPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin
    implements Post {
  SzurubooruPost({
    required this.id,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    required this.source,
    required this.score,
    required this.duration,
    required this.fileSize,
    required this.format,
    required this.hasSound,
    required this.height,
    required this.md5,
    required this.videoThumbnailUrl,
    required this.videoUrl,
    required this.width,
    required this.ownFavorite,
    required this.uploaderName,
    required this.favoriteCount,
    required this.commentCount,
    required this.metadata,
    required this.tagDetails,
    this.createdAt,
    this.parentId,
    this.downvotes,
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
  int? get uploaderId => null;

  final String? uploaderName;

  @override
  String getLink(String baseUrl) =>
      baseUrl.endsWith('/') ? '${baseUrl}post/$id' : '$baseUrl/post/$id';

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  final bool ownFavorite;
  final int favoriteCount;
  final int commentCount;

  @override
  final PostMetadata? metadata;

  final List<Tag> tagDetails;

  @override
  List<Object?> get props => [id];
}
