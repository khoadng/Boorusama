// Project imports:
import '../../../../images/types.dart';
import '../../../post/types.dart';
import 'animated_posts_default_state.dart';
import 'grid_size.dart';
import 'grid_thumbnail_url_generator.dart';

String defaultImageQualityMapper(
  Post post,
  GridThumbnailSettings settings,
) {
  return switch (settings.imageQuality) {
    ImageQuality.automatic => post.thumbnailImageUrl,
    ImageQuality.low => post.thumbnailImageUrl,
    ImageQuality.high =>
      post.isVideo
          ? post.thumbnailImageUrl
          : switch (settings.gridSize) {
              GridSize.micro || GridSize.tiny => post.thumbnailImageUrl,
              _ => post.sampleImageUrl,
            },
    ImageQuality.highest =>
      post.isVideo
          ? post.thumbnailImageUrl
          : switch (settings.gridSize) {
              GridSize.micro || GridSize.tiny => post.thumbnailImageUrl,
              _ => post.originalImageUrl,
            },
    ImageQuality.original =>
      post.isVideo ? post.thumbnailImageUrl : post.originalImageUrl,
  };
}

String defaultGifImageQualityMapper(
  Post post,
  GridThumbnailSettings settings,
) {
  return switch (settings.imageQuality) {
    ImageQuality.automatic => switch (settings.animatedPostsDefaultState) {
      AnimatedPostsDefaultState.autoplay => post.sampleImageUrl,
      AnimatedPostsDefaultState.static => post.thumbnailImageUrl,
    },
    ImageQuality.low => post.thumbnailImageUrl,
    ImageQuality.high => post.sampleImageUrl,
    ImageQuality.highest => post.sampleImageUrl,
    ImageQuality.original => post.originalImageUrl,
  };
}

String thumbnailOnlyGifImageQualityMapper(
  Post post,
  GridThumbnailSettings settings,
) => post.thumbnailImageUrl;

String thumbnailOnlyImageQualityMapper(
  Post post,
  GridThumbnailSettings settings,
) => post.thumbnailImageUrl;

class DefaultGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DefaultGridThumbnailUrlGenerator({
    this.imageQualityMapper,
    this.gifImageQualityMapper,
  });

  const DefaultGridThumbnailUrlGenerator.thumbnailOnly()
    : imageQualityMapper = thumbnailOnlyImageQualityMapper,
      gifImageQualityMapper = thumbnailOnlyGifImageQualityMapper;

  final ImageQualityMapper? imageQualityMapper;
  final GifImageQualityMapper? gifImageQualityMapper;

  GifImageQualityMapper get _gifMapper =>
      gifImageQualityMapper ?? defaultGifImageQualityMapper;

  ImageQualityMapper get _imageMapper =>
      imageQualityMapper ?? defaultImageQualityMapper;

  @override
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  }) => switch (post.isGif) {
    true => _gifMapper(post, settings),
    false => _imageMapper(post, settings),
  };
}
