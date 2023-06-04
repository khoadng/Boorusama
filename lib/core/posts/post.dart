// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/image.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/video.dart';

abstract class Post extends Equatable
    with MediaInfoMixin, ImageInfoMixin, VideoInfoMixin {
  int get id;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  List<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  PostSource get source;
  int get score;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}

extension PostImageX on Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

  String thumbnailFromSettings(Settings settings) =>
      switch (settings.imageQuality) {
        ImageQuality.automatic => thumbnailImageUrl,
        ImageQuality.low => thumbnailImageUrl,
        ImageQuality.high => sampleImageUrl,
        ImageQuality.original => originalImageUrl
      };
}
