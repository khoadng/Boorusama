// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';

class MoebooruPost extends Equatable
    with MediaInfoMixin, TranslatedMixin
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

  final int id;
  final List<String> tags;
  final String? source;
  final String thumbnailImageUrl;
  final String sampleImageUrl;
  final String sampleLargeImageUrl;
  final String originalImageUrl;
  final Rating rating;
  final bool hasComment;
  final bool isTranslated;
  final bool hasParentOrChildren;
  final String downloadUrl;

  final String format;
  final double width;
  final double height;
  final String md5;
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
