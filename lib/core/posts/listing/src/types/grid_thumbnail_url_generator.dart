// Project imports:
import '../../../../settings/settings.dart';
import '../../../post/post.dart';

abstract class GridThumbnailUrlGenerator {
  String generateThumbnailUrl(Post post);
}

class DefaultGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DefaultGridThumbnailUrlGenerator({
    required this.imageQuality,
  });

  final ImageQuality imageQuality;

  @override
  String generateThumbnailUrl(
    Post post,
  ) {
    return switch (imageQuality) {
      ImageQuality.automatic => post.thumbnailImageUrl,
      ImageQuality.low => post.thumbnailImageUrl,
      ImageQuality.high =>
        post.isVideo ? post.thumbnailImageUrl : post.sampleImageUrl,
      ImageQuality.highest =>
        post.isVideo ? post.thumbnailImageUrl : post.sampleImageUrl,
      ImageQuality.original =>
        post.isVideo ? post.thumbnailImageUrl : post.originalImageUrl
    };
  }
}
