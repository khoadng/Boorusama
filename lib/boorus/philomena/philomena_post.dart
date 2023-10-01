// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class PhilomenaPost extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
    implements Post {
  PhilomenaPost({
    required this.id,
    this.createdAt,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.isTranslated,
    required this.hasParentOrChildren,
    this.parentId,
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
    required Function(String baseUrl) getLink,
    required this.description,
    required this.commentCount,
    required this.favCount,
    required this.upvotes,
    required this.downvotes,
  }) : _getLink = getLink;

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
  final List<String> tags;
  @override
  final Rating rating;
  @override
  bool get hasComment => commentCount > 0;
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
  final int downvotes;
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

  final Function(String baseUrl) _getLink;

  @override
  String getLink(String baseUrl) => _getLink(baseUrl);

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  List<Object?> get props => [id];

  @override
  List<String>? get artistTags => _findArtistFromTags(tags);

  @override
  List<String>? get characterTags => null;

  @override
  List<String>? get copyrightTags => null;

  final String description;
  final int commentCount;
  final int favCount;
  final int upvotes;
}

List<String>? _findArtistFromTags(List<String> tags) {
  const metaTag = 'artist:';
  final artistTag = tags.firstWhereOrNull((e) => e.startsWith(metaTag));
  return artistTag != null ? [artistTag.substring(metaTag.length)] : null;
}
