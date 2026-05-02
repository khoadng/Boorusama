// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/images/types.dart';
import '../../../../../core/posts/listing/types.dart';
import '../../../../../core/posts/post/types.dart';
import '../../post/types.dart';

class DanbooruGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DanbooruGridThumbnailUrlGenerator();

  @override
  GridThumbnailMedia resolve(
    Post post, {
    required GridThumbnailSettings settings,
  }) {
    return castOrNull<DanbooruPost>(post).toOption().fold(
      () => const DefaultGridThumbnailUrlGenerator().resolve(
        post,
        settings: settings,
      ),
      (post) {
        final media = defaultGridThumbnailMedia(post, settings);

        return GridThumbnailMedia(
          url: _danbooruGridThumbnailUrl(post, settings),
          aspectRatio: media.aspectRatio,
          placeholderUrl: media.placeholderUrl,
          placeholderAspectRatio: media.placeholderAspectRatio,
          placeholderFit: media.placeholderFit,
        );
      },
    );
  }
}

String _danbooruGridThumbnailUrl(
  DanbooruPost post,
  GridThumbnailSettings settings,
) => switch (settings.imageQuality) {
  ImageQuality.automatic => switch (settings.gridSize) {
    GridSize.micro => post.url180x180,
    GridSize.tiny => post.url360x360,
    _ => post.url720x720,
  },
  ImageQuality.low => switch (settings.gridSize) {
    GridSize.micro || GridSize.tiny => post.url180x180,
    _ => post.url360x360,
  },
  ImageQuality.high => switch (settings.gridSize) {
    GridSize.micro => post.url180x180,
    GridSize.tiny => post.url360x360,
    _ => post.url720x720,
  },
  ImageQuality.highest =>
    post.isVideo
        ? post.url720x720
        : switch (settings.gridSize) {
            GridSize.micro => post.url360x360,
            GridSize.tiny => post.url720x720,
            _ => post.urlSample,
          },
  ImageQuality.original => post.urlOriginal,
};
