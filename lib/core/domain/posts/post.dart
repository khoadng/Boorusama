// Project imports:
import 'package:boorusama/core/domain/image.dart';
import 'package:boorusama/core/domain/posts.dart';

abstract class Post with MediaInfoMixin, ImageInfoMixin, SourceMixin {
  int get id;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get sampleLargeImageUrl;
  String get originalImageUrl;
  List<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  String get downloadUrl;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}
