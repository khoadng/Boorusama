// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/posts/posts.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class MoebooruPost extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
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
  });

  @override
  final int id;
  @override
  final List<String> tags;
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
  String getLink(String baseUrl) {
    return '$baseUrl/post/show/$id';
  }

  @override
  Uri getUriLink(String baseUrl) {
    return Uri.parse(getLink(baseUrl));
  }

  @override
  List<Object?> get props => [id];

  @override
  double get duration => -1;
}
