// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

class E621Post extends Equatable
    with MediaInfoMixin, TranslatedMixin, ImageInfoMixin, VideoInfoMixin
    implements Post {
  E621Post({
    required this.id,
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
    required this.duration,
    required this.characterTags,
    required this.copyrightTags,
    required this.artistTags,
    required this.generalTags,
    required this.metaTags,
    required this.speciesTags,
    required this.invalidTags,
    required this.loreTags,
    required this.upScore,
    required this.downScore,
    required this.favCount,
    required this.isFavorited,
    required this.sources,
    required this.description,
    required this.videoUrl,
  });

  @override
  final int id;
  @override
  List<String> get tags => [
        ...characterTags,
        ...artistTags,
        ...generalTags,
        ...copyrightTags,
        ...metaTags,
        ...speciesTags,
        ...invalidTags,
        ...loreTags,
      ];
  final List<String> copyrightTags;
  final List<String> characterTags;
  final List<String> artistTags;
  final List<String> generalTags;
  final List<String> metaTags;
  final List<String> loreTags;
  final List<String> invalidTags;
  final List<String> speciesTags;
  @override
  final PostSource source;
  final List<PostSource> sources;
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
  final int upScore;
  final int downScore;
  final int favCount;
  final bool isFavorited;
  final String description;
  final String videoUrl;

  @override
  String getLink(String baseUrl) =>
      baseUrl.endsWith('/') ? '${baseUrl}posts/$id' : '$baseUrl/posts/$id';

  @override
  Uri getUriLink(String baseUrl) {
    return Uri.parse(getLink(baseUrl));
  }

  @override
  List<Object?> get props => [id];

  @override
  final double duration;

  @override
  final DateTime createdAt;
}

extension PostImageX on E621Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

  String thumbnailFromSettings(Settings settings) =>
      switch (settings.imageQuality) {
        ImageQuality.automatic => sampleImageUrl,
        ImageQuality.low => thumbnailImageUrl,
        ImageQuality.high => sampleImageUrl,
        ImageQuality.highest => sampleImageUrl,
        ImageQuality.original => originalImageUrl
      };

  bool get hasNoImage =>
      thumbnailImageUrl.isEmpty &&
      sampleImageUrl.isEmpty &&
      originalImageUrl.isEmpty;
}
