// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/images/types.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../../../core/posts/listing/types.dart';
import '../../../../../core/posts/post/types.dart';
import '../../post/types.dart';

class DanbooruGridThumbnailUrlGenerator implements GridThumbnailUrlGenerator {
  const DanbooruGridThumbnailUrlGenerator();

  @override
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  }) {
    return castOrNull<DanbooruPost>(post).toOption().fold(
      () => const DefaultGridThumbnailUrlGenerator().generateUrl(
        post,
        settings: settings,
      ),
      (post) =>
          DefaultGridThumbnailUrlGenerator(
            gifImageQualityMapper: (_, _) => post.sampleImageUrl,
            imageQualityMapper: (_, imageQuality, gridSize) =>
                switch (imageQuality) {
                  ImageQuality.automatic => switch (gridSize) {
                    GridSize.micro => post.url180x180,
                    GridSize.tiny => post.url360x360,
                    _ => post.url720x720,
                  },
                  ImageQuality.low => switch (gridSize) {
                    GridSize.micro || GridSize.tiny => post.url180x180,
                    _ => post.url360x360,
                  },
                  ImageQuality.high => switch (gridSize) {
                    GridSize.micro => post.url180x180,
                    GridSize.tiny => post.url360x360,
                    _ => post.url720x720,
                  },
                  ImageQuality.highest =>
                    post.isVideo
                        ? post.url720x720
                        : switch (gridSize) {
                            GridSize.micro => post.url360x360,
                            GridSize.tiny => post.url720x720,
                            _ => post.urlSample,
                          },
                  ImageQuality.original => post.urlOriginal,
                },
          ).generateUrl(
            post,
            settings: settings,
          ),
    );
  }
}
