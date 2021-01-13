import 'package:boorusama/domain/posts/tag_string.dart';
import 'package:meta/meta.dart';

class PostViewModel {
  final int id;
  final bool isTranslated;
  final bool isAnimated;
  final bool isVideo;
  final bool hasComment;
  final TagString tagString;
  final String lowResSource;
  final String highResSource;
  final String mediumResSource;
  final double aspectRatio;
  final String descriptiveName;
  final String downloadLink;
  final int favCount;
  final double height;
  final double width;

  PostViewModel({
    @required this.id,
    @required this.isTranslated,
    @required this.isAnimated,
    @required this.hasComment,
    @required this.isVideo,
    @required this.tagString,
    @required this.lowResSource,
    @required this.mediumResSource,
    @required this.highResSource,
    @required this.aspectRatio,
    @required this.descriptiveName,
    @required this.downloadLink,
    @required this.favCount,
    @required this.height,
    @required this.width,
  });
}
