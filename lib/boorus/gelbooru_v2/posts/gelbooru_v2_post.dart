// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class GelbooruV2Post extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin,
        TagListCheckMixin
    implements Post {
  const GelbooruV2Post({
    required this.format,
    required this.height,
    required this.id,
    required this.md5,
    required this.originalImageUrl,
    required this.rating,
    required String sampleImageUrl,
    required this.source,
    required this.tags,
    required this.thumbnailImageUrl,
    required this.width,
    required this.hasComment,
    required this.hasParentOrChildren,
    required this.fileSize,
    required this.score,
    required this.createdAt,
    required this.parentId,
    required this.uploaderId,
    required this.uploaderName,
    required this.hasNotes,
    required this.metadata,
  }) : _sampleImageUrl = sampleImageUrl;

  factory GelbooruV2Post.empty() => GelbooruV2Post(
        format: '',
        height: 0.0,
        id: 0,
        md5: '',
        originalImageUrl: '',
        rating: Rating.general,
        sampleImageUrl: '',
        source: PostSource.none(),
        tags: const {},
        thumbnailImageUrl: '',
        width: 0.0,
        hasComment: false,
        hasParentOrChildren: false,
        fileSize: 0,
        score: 0,
        createdAt: null,
        parentId: null,
        uploaderId: null,
        uploaderName: null,
        hasNotes: false,
        metadata: null,
      );

  final String _sampleImageUrl;

  @override
  final String format;

  @override
  String getLink(String baseUrl) => baseUrl.endsWith('/')
      ? '${baseUrl}index.php?page=post&s=view&id=$id'
      : '$baseUrl/index.php?page=post&s=view&id=$id';

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  final double height;

  @override
  final int id;

  @override
  final String md5;

  @override
  final String originalImageUrl;

  @override
  List<Object?> get props => [id];

  @override
  final Rating rating;

  @override
  String get sampleImageUrl =>
      _sampleImageUrl.isEmpty ? originalImageUrl : _sampleImageUrl;

  @override
  final PostSource source;

  @override
  final Set<String> tags;

  @override
  final String thumbnailImageUrl;

  @override
  final double width;

  @override
  final bool hasComment;

  @override
  final bool hasParentOrChildren;

  @override
  final int fileSize;

  @override
  double get duration => -1;

  @override
  final int score;

  @override
  final DateTime? createdAt;

  @override
  int? get downvotes => null;

  @override
  bool? get hasSound => tags.contains('sound') ? true : null;
  @override
  String get videoUrl => originalImageUrl;
  @override
  String get videoThumbnailUrl => thumbnailImageUrl;

  @override
  final int? parentId;

  @override
  final int? uploaderId;

  final String? uploaderName;

  final bool hasNotes;

  @override
  final PostMetadata? metadata;
}
