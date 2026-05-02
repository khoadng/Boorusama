// Project imports:
import '../../../../images/types.dart';
import '../../../post/types.dart';
import 'animated_posts_default_state.dart';
import 'grid_size.dart';
import 'grid_thumbnail_url_generator.dart';

GridThumbnailMedia defaultGridThumbnailMedia(
  Post post,
  GridThumbnailSettings settings,
) {
  final aspectRatio = switch (post.isGif) {
    true => switch (settings.imageQuality) {
      ImageQuality.automatic => switch (settings.animatedPostsDefaultState) {
        AnimatedPostsDefaultState.autoplay => post.effectiveSampleAspectRatio,
        AnimatedPostsDefaultState.static => post.effectiveThumbnailAspectRatio,
      },
      ImageQuality.low => post.effectiveThumbnailAspectRatio,
      ImageQuality.high => post.effectiveSampleAspectRatio,
      ImageQuality.highest => post.effectiveSampleAspectRatio,
      ImageQuality.original => post.effectiveOriginalAspectRatio,
    },
    false => switch (settings.imageQuality) {
      ImageQuality.automatic => post.effectiveThumbnailAspectRatio,
      ImageQuality.low => post.effectiveThumbnailAspectRatio,
      ImageQuality.high =>
        post.isVideo
            ? post.effectiveVideoThumbnailAspectRatio
            : switch (settings.gridSize) {
                GridSize.micro ||
                GridSize.tiny => post.effectiveThumbnailAspectRatio,
                _ => post.effectiveSampleAspectRatio,
              },
      ImageQuality.highest =>
        post.isVideo
            ? post.effectiveVideoThumbnailAspectRatio
            : switch (settings.gridSize) {
                GridSize.micro ||
                GridSize.tiny => post.effectiveThumbnailAspectRatio,
                _ => post.effectiveOriginalAspectRatio,
              },
      ImageQuality.original =>
        post.isVideo
            ? post.effectiveVideoThumbnailAspectRatio
            : post.effectiveOriginalAspectRatio,
    },
  };

  return GridThumbnailMedia(
    url: switch (post.isGif) {
      true => switch (settings.imageQuality) {
        ImageQuality.automatic => switch (settings.animatedPostsDefaultState) {
          AnimatedPostsDefaultState.autoplay => post.sampleImageUrl,
          AnimatedPostsDefaultState.static => post.thumbnailImageUrl,
        },
        ImageQuality.low => post.thumbnailImageUrl,
        ImageQuality.high => post.sampleImageUrl,
        ImageQuality.highest => post.sampleImageUrl,
        ImageQuality.original => post.originalImageUrl,
      },
      false => switch (settings.imageQuality) {
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
      },
    },
    aspectRatio: aspectRatio,
    placeholderUrl: post.thumbnailImageUrl,
    placeholderAspectRatio: aspectRatio,
  );
}

GridThumbnailMedia _thumbnailOnlyGridThumbnailMedia(
  Post post,
  GridThumbnailSettings settings,
) {
  final aspectRatio = post.effectiveThumbnailAspectRatio;

  return GridThumbnailMedia(
    url: post.thumbnailImageUrl,
    aspectRatio: aspectRatio,
    placeholderUrl: post.thumbnailImageUrl,
    placeholderAspectRatio: aspectRatio,
  );
}

class DefaultGridThumbnailUrlGenerator
    implements
        GridThumbnailUrlGenerator,
        GridLoadingPlaceholderAspectRatioResolver {
  const DefaultGridThumbnailUrlGenerator({
    this.mediaMapper,
    this.loadingPlaceholderAspectRatioResolver,
  });

  const DefaultGridThumbnailUrlGenerator.thumbnailOnly()
    : mediaMapper = _thumbnailOnlyGridThumbnailMedia,
      loadingPlaceholderAspectRatioResolver = null;

  final GridThumbnailMediaMapper? mediaMapper;
  final double? Function(GridThumbnailSettings settings)?
  loadingPlaceholderAspectRatioResolver;

  @override
  GridThumbnailMedia resolve(
    Post post, {
    required GridThumbnailSettings settings,
  }) => (mediaMapper ?? defaultGridThumbnailMedia)(post, settings);

  @override
  double? resolveLoadingPlaceholderAspectRatio({
    required GridThumbnailSettings settings,
  }) => loadingPlaceholderAspectRatioResolver?.call(settings);
}
