// Project imports:
import 'package:boorusama/core/posts/post/src/types/post.dart';
import 'package:boorusama/core/posts/rating/src/rating.dart';
import 'package:boorusama/core/posts/sources/src/source.dart';

class DummyPost implements Post {
  DummyPost({
    this.artistTags,
    this.aspectRatio,
    this.characterTags,
    this.copyrightTags,
    this.createdAt,
    this.downvotes,
    this.duration = 0,
    this.fileSize = 0,
    this.format = '',
    this.hasComment = false,
    this.hasParentOrChildren = false,
    this.hasSound,
    this.height = 0,
    this.id = 0,
    this.isAnimated = false,
    this.isFlash = false,
    this.isGif = false,
    this.isMp4 = false,
    this.isTranslated = false,
    this.isVideo = false,
    this.isWebm = false,
    this.md5 = '',
    this.metadata,
    this.mpixels = 0,
    this.originalImageUrl = '',
    this.parentId,
    this.rating = Rating.unknown,
    this.sampleImageUrl = '',
    this.score = 0,
    PostSource? source,
    this.tags = const {},
    this.thumbnailImageUrl = '',
    this.uploaderId,
    this.uploaderName,
    this.videoThumbnailUrl = '',
    this.videoUrl = '',
    this.width = 0,
    this.status,
  }) : source = source ?? PostSource.none();

  @override
  final Set<String>? artistTags;
  @override
  final double? aspectRatio;
  @override
  final Set<String>? characterTags;
  @override
  final Set<String>? copyrightTags;
  @override
  final DateTime? createdAt;
  @override
  final int? downvotes;
  @override
  final double duration;
  @override
  final int fileSize;
  @override
  final String format;
  @override
  final bool hasComment;
  @override
  final bool hasParentOrChildren;
  @override
  final bool? hasSound;
  @override
  final double height;
  @override
  final int id;
  @override
  final bool isAnimated;
  @override
  final bool isFlash;
  @override
  final bool isGif;
  @override
  final bool isMp4;
  @override
  final bool isTranslated;
  @override
  final bool isVideo;
  @override
  final bool isWebm;
  @override
  final String md5;
  @override
  final PostMetadata? metadata;
  @override
  final double mpixels;
  @override
  final String originalImageUrl;
  @override
  final int? parentId;
  @override
  final Rating rating;
  @override
  final String sampleImageUrl;
  @override
  final int score;
  @override
  final PostSource source;
  @override
  final Set<String> tags;
  @override
  final String thumbnailImageUrl;
  @override
  final int? uploaderId;
  @override
  final String? uploaderName;
  @override
  final String videoThumbnailUrl;
  @override
  final String videoUrl;
  @override
  final double width;
  @override
  final PostStatus? status;
}
