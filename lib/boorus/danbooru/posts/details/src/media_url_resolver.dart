// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/details/details.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/settings/settings.dart';
import '../../post/post.dart';

class DanbooruMediaUrlResolver implements MediaUrlResolver {
  DanbooruMediaUrlResolver({
    required this.imageQuality,
  });

  final ImageQuality imageQuality;

  @override
  String resolveMediaUrl(
    Post rawPost,
    BooruConfigViewer config,
  ) => castOrNull<DanbooruPost>(rawPost).toOption().fold(
    () => rawPost.sampleImageUrl,
    (post) => post.isGif
        ? post.sampleImageUrl
        : config.imageDetaisQuality.toOption().fold(
            () => switch (imageQuality) {
              ImageQuality.highest ||
              ImageQuality.original => post.sampleImageUrl,
              _ => post.url720x720,
            },
            (quality) => switch (PostQualityType.parse(quality)) {
              PostQualityType.v180x180 => post.url180x180,
              PostQualityType.v360x360 => post.url360x360,
              PostQualityType.v720x720 => post.url720x720,
              PostQualityType.sample =>
                post.isVideo ? post.url720x720 : post.sampleImageUrl,
              PostQualityType.original =>
                post.isVideo ? post.url720x720 : post.originalImageUrl,
              null => post.url720x720,
            },
          ),
  );

  @override
  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.videoUrl;
}
