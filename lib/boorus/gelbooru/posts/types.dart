// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/posts/post/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/posts/sources/types.dart';

class GelbooruPost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin
    implements Post {
  const GelbooruPost({
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
    required this.metadata,
    required this.status,
  }) : _sampleImageUrl = sampleImageUrl;

  factory GelbooruPost.empty() => GelbooruPost(
    format: '',
    height: 0,
    id: 0,
    md5: '',
    originalImageUrl: '',
    rating: Rating.general,
    sampleImageUrl: '',
    source: PostSource.none(),
    tags: const {},
    thumbnailImageUrl: '',
    width: 0,
    hasComment: false,
    hasParentOrChildren: false,
    fileSize: 0,
    score: 0,
    createdAt: null,
    parentId: null,
    uploaderId: null,
    uploaderName: null,
    metadata: null,
    status: null,
  );

  final String _sampleImageUrl;

  @override
  final String format;

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

  @override
  final String? uploaderName;

  @override
  final PostMetadata? metadata;

  @override
  final PostStatus? status;
}

class GelbooruImageUrlResolver implements ImageUrlResolver {
  const GelbooruImageUrlResolver();

  static const _currentImageHost = 'img2.gelbooru.com';
  static final _imgHostPattern = RegExp(r'^img\d+\.gelbooru\.com$');

  @override
  String resolveImageUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return url;
    }

    // Normalize any imgN.gelbooru.com to the current host
    if (_imgHostPattern.hasMatch(uri.host)) {
      final newUri = uri.replace(host: _currentImageHost);
      return newUri.toString();
    }

    return url;
  }

  @override
  String resolvePreviewUrl(String url) => resolveImageUrl(url);

  @override
  String resolveThumbnailUrl(String url) => resolveImageUrl(url);
}
