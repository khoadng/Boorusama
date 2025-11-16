// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';
import '../../../core/tags/tag/types.dart';

class SankakuPost extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
    implements Post {
  SankakuPost({
    required this.id,
    required this.sankakuId,
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
    required this.artistDetailsTags,
    required this.characterDetailsTags,
    required this.copyrightDetailsTags,
    required this.generalDetailsTags,
    required this.metaDetailsTags,
    required this.uploaderId,
    required this.uploaderName,
    required this.metadata,
    required this.status,
    this.createdAt,
    this.parentId,
    this.downvotes,
  }) : artistTags = artistDetailsTags.map((e) => e.name).toSet(),
       characterTags = characterDetailsTags.map((e) => e.name).toSet(),
       copyrightTags = copyrightDetailsTags.map((e) => e.name).toSet(),
       generalTags = generalDetailsTags.map((e) => e.name).toSet(),
       metaTags = metaDetailsTags.map((e) => e.name).toSet();

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
  List<Object?> get props => [id];

  @override
  final Set<String> artistTags;

  @override
  final Set<String> characterTags;

  @override
  final Set<String> copyrightTags;

  final Set<String> generalTags;

  final Set<String> metaTags;

  final List<Tag> artistDetailsTags;

  final List<Tag> characterDetailsTags;

  final List<Tag> copyrightDetailsTags;

  final List<Tag> generalDetailsTags;

  final List<Tag> metaDetailsTags;

  @override
  final int? uploaderId;

  @override
  final String? uploaderName;

  final String sankakuId;

  @override
  final PostMetadata? metadata;

  @override
  final PostStatus? status;
}

class SankakuPostLinkGenerator implements PostLinkGenerator<SankakuPost> {
  SankakuPostLinkGenerator({
    required this.baseUrl,
  });

  final String baseUrl;

  @override
  String getLink(Post post) => switch (post) {
    final SankakuPost post => _getLink(post),
    _ => '',
  };

  String _getLink(SankakuPost post) {
    final id = _getId(post);

    if (id == null) return '';

    final url = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$url/post/$id';
  }

  String? _getId(SankakuPost post) {
    if (post.sankakuId.isNotEmpty) return post.sankakuId;
    if (post.id != 0) return post.id.toString();

    return null;
  }
}
