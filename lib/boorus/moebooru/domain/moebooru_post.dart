// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/image.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/source_mixin.dart';

class MoebooruPost extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, SourceMixin
    implements Post {
  MoebooruPost({
    required this.id,
    required this.tags,
    this.source,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.sampleLargeImageUrl,
    required this.originalImageUrl,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    required this.downloadUrl,
    required this.format,
    required this.width,
    required this.height,
    required this.md5,
    required this.fileSize,
  });

  @override
  final int id;
  @override
  final List<String> tags;
  @override
  final String? source;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String sampleLargeImageUrl;
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
  final String downloadUrl;

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
  String getLink(String baseUrl) {
    return '$baseUrl/post/show/$id';
  }

  @override
  Uri getUriLink(String baseUrl) {
    return Uri.parse(getLink(baseUrl));
  }

  @override
  List<Object?> get props => [id];
}
