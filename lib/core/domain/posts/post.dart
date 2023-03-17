// Project imports:
import 'package:boorusama/core/domain/posts/media_info_mixin.dart';

import 'rating.dart';

abstract class Post with MediaInfoMixin {
  int get id;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get sampleLargeImageUrl;
  String get originalImageUrl;
  List<String> get tags;
  String? get source;
  Rating get rating;
  bool get hasComment;

  String get downloadUrl;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}
