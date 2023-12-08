// Project imports:
import 'package:boorusama/foundation/video.dart';

mixin MediaInfoMixin {
  String get format;
  String get md5;
  int get fileSize;

  bool get isVideo => isFormatVideo(format);

  bool get isAnimated {
    return isVideo || (format == 'gif') || (format == '.gif');
  }
}
