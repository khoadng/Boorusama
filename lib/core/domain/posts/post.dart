// Project imports:
import 'rating.dart';

abstract class Post {
  int get id;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  List<String> get tags;
  String? get source;
  Rating get rating;
  String get format;
  double get width;
  double get height;

  String get downloadUrl;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}
