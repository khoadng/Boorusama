// Project imports:
import 'package:boorusama/core/domain/image.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';

abstract class Post with MediaInfoMixin, ImageInfoMixin {
  int get id;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  List<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  String get downloadUrl;
  PostSource get source;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}

extension PostImageX on Post {
  String thumbnailFromSettings(Settings settings) =>
      switch (settings.imageQuality) {
        ImageQuality.automatic => thumbnailImageUrl,
        ImageQuality.low => thumbnailImageUrl,
        ImageQuality.high => sampleImageUrl,
        ImageQuality.original => originalImageUrl
      };
}
