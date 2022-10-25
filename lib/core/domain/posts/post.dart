// Project imports:
import 'rating.dart';

abstract class Post {
  String get previewImageUrl;
  String get normalImageUrl;
  String get fullImageUrl;
  List<String> get tags;
  String? get source;
  Rating get rating;
  String get format;
  double get width;
  double get height;
}
