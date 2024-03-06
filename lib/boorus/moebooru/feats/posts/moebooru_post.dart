// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class MoebooruPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin,
        TagListCheckMixin
    implements Post {
  MoebooruPost({
    required this.id,
    required this.tags,
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
    required this.parentId,
    required this.uploaderId,
    required this.uploaderName,
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
  String getLink(String baseUrl) => baseUrl.endsWith('/')
      ? '${baseUrl}post/show/$id'
      : '$baseUrl/post/show/$id';

  @override
  Uri getUriLink(String baseUrl) {
    return Uri.parse(getLink(baseUrl));
  }

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

  final String? uploaderName;
}
