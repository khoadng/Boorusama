// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/posts/media_info_mixin.dart';
import 'package:boorusama/core/domain/posts/post.dart' as base;
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:boorusama/core/domain/posts/translatable_mixin.dart';

class GelbooruPost extends Equatable
    with MediaInfoMixin, TranslatedMixin
    implements base.Post {
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
  }) : _sampleImageUrl = sampleImageUrl;

  final String _sampleImageUrl;

  @override
  String get downloadUrl => isVideo ? sampleImageUrl : originalImageUrl;

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
  String get sampleLargeImageUrl => sampleImageUrl;

  @override
  final String? source;

  @override
  final List<String> tags;

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
}
