// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/posts/post/post.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';

class E621Post extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
    implements Post {
  E621Post({
    required this.id,
    required this.source,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
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
    required this.duration,
    required this.characterTags,
    required this.copyrightTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.speciesTags,
    required this.invalidTags,
    required this.loreTags,
    required this.upScore,
    required this.downScore,
    required this.favCount,
    required this.isFavorited,
    required this.sources,
    required this.description,
    required this.videoUrl,
    required this.parentId,
    required this.uploaderId,
    required this.metadata,
  });

  @override
  final int id;
  @override
  Set<String> get tags => {
    ...characterTags,
    ...artistTags,
    ...generalTags,
    ...copyrightTags,
    ...metaTags,
    ...speciesTags,
    ...invalidTags,
    ...loreTags,
  };
  @override
  final Set<String> copyrightTags;
  @override
  final Set<String> characterTags;
  @override
  final Set<String> artistTags;
  final Set<String> generalTags;
  final Set<String> metaTags;
  final Set<String> loreTags;
  final Set<String> invalidTags;
  final Set<String> speciesTags;
  @override
  final PostSource source;
  final List<PostSource> sources;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
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
  final int upScore;
  final int downScore;
  final int favCount;
  final bool isFavorited;
  final String description;

  @override
  int? get downvotes => -downScore;

  @override
  bool? get hasSound => metaTags.contains('sound') ? true : null;
  @override
  final String videoUrl;
  @override
  String get videoThumbnailUrl => sampleImageUrl;

  @override
  List<Object?> get props => [id];

  @override
  final double duration;

  @override
  final DateTime createdAt;

  @override
  final int? parentId;

  @override
  final int? uploaderId;

  @override
  String? get uploaderName => null;

  @override
  final PostMetadata? metadata;
}
