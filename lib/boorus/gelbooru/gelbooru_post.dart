// Package imports:
import 'package:boorusama/core/domain/posts/rating.dart';
import 'package:equatable/equatable.dart';

import 'package:boorusama/core/domain/posts/media_info_mixin.dart';
import 'package:boorusama/core/domain/posts/translatable_mixin.dart';
import 'package:boorusama/core/domain/posts/post.dart' as base;

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
    required this.sampleImageUrl,
    required this.sampleLargeImageUrl,
    required this.source,
    required this.tags,
    required this.thumbnailImageUrl,
    required this.width,
    required this.downloadUrl,
    required this.hasComment,
  });

  @override
  final String downloadUrl;
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
  final String sampleImageUrl;

  @override
  final String sampleLargeImageUrl;

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
}
