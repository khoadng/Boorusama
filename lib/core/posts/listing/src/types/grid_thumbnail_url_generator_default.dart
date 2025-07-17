// Project imports:
import '../../../../settings/settings.dart';
import '../../../post/post.dart';
import 'grid_thumbnail_url_generator.dart';

String defaultImageQualityMapper(
  Post post,
  ImageQuality imageQuality,
  GridSize gridSize,
) {
  return switch (imageQuality) {
    ImageQuality.automatic => post.thumbnailImageUrl,
    ImageQuality.low => post.thumbnailImageUrl,
    ImageQuality.high =>
      post.isVideo
          ? post.thumbnailImageUrl
          : switch (gridSize) {
              GridSize.micro || GridSize.tiny => post.thumbnailImageUrl,
              _ => post.sampleImageUrl,
            },
    ImageQuality.highest =>
      post.isVideo
          ? post.thumbnailImageUrl
          : switch (gridSize) {
              GridSize.micro || GridSize.tiny => post.thumbnailImageUrl,
              _ => post.originalImageUrl,
            },
    ImageQuality.original =>
      post.isVideo ? post.thumbnailImageUrl : post.originalImageUrl,
  };
}

String defaultGifImageQualityMapper(
  Post post,
  ImageQuality imageQuality,
) {
  return switch (imageQuality) {
    ImageQuality.automatic => post.thumbnailImageUrl,
    ImageQuality.low => post.thumbnailImageUrl,
    ImageQuality.high => post.sampleImageUrl,
    ImageQuality.highest => post.sampleImageUrl,
    ImageQuality.original => post.originalImageUrl,
  };
}

class DefaultGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DefaultGridThumbnailUrlGenerator({
    this.imageQualityMapper,
    this.gifImageQualityMapper,
  });

  final ImageQualityMapper? imageQualityMapper;
  final GifImageQualityMapper? gifImageQualityMapper;

  @override
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  }) {
    if (post.isGif) {
      if (settings.animatedPostsDefaultState ==
          AnimatedPostsDefaultState.static) {
        return post.thumbnailImageUrl;
      }

      final gifMapper = gifImageQualityMapper ?? defaultGifImageQualityMapper;
      return gifMapper(
        post,
        settings.imageQuality,
      );
    }

    final mapper = imageQualityMapper ?? defaultImageQualityMapper;

    return mapper(
      post,
      settings.imageQuality,
      settings.gridSize,
    );
  }
}
