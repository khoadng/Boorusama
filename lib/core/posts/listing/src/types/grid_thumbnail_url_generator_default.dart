// Project imports:
import '../../../../settings/settings.dart';
import '../../../post/post.dart';
import 'grid_thumbnail_url_generator.dart';

String defaultImageQualityMapper(
  Post post,
  ImageQuality imageQuality,
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

String defaultGifImageQualityMapper(
  Post post,
  ImageQuality imageQuality,
) {
  return switch (imageQuality) {
    ImageQuality.automatic => post.thumbnailImageUrl,
    ImageQuality.low => post.thumbnailImageUrl,
    ImageQuality.high => post.sampleImageUrl,
    ImageQuality.highest => post.sampleImageUrl,
    ImageQuality.original => post.originalImageUrl
  };
}

class DefaultGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DefaultGridThumbnailUrlGenerator({
    required this.imageQuality,
    required this.animatedPostsDefaultState,
    this.imageQualityMapper,
    this.gifImageQualityMapper,
  });

  final ImageQuality imageQuality;
  final AnimatedPostsDefaultState animatedPostsDefaultState;
  final ImageQualityMapper? imageQualityMapper;
  final GifImageQualityMapper? gifImageQualityMapper;

  @override
  String generateThumbnailUrl(Post post) {
    if (post.isGif) {
      if (animatedPostsDefaultState == AnimatedPostsDefaultState.static) {
        return post.thumbnailImageUrl;
      }

      final gifMapper = gifImageQualityMapper ?? defaultGifImageQualityMapper;
      return gifMapper(
        post,
        imageQuality,
      );
    }

    final mapper = imageQualityMapper ?? defaultImageQualityMapper;

    return mapper(
      post,
      imageQuality,
    );
  }
}
