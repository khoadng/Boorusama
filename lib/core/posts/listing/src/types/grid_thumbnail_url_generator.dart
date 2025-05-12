// Project imports:
import '../../../../settings/settings.dart';
import '../../../post/post.dart';

abstract class GridThumbnailUrlGenerator {
  String generateThumbnailUrl(Post post);
}

typedef ImageQualityMapper = String Function(
  Post post,
  ImageQuality imageQuality,
);

typedef GifImageQualityMapper = String Function(
  Post post,
  ImageQuality imageQuality,
);
