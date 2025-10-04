// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../settings/settings.dart';
import '../../../post/post.dart';

abstract class MediaUrlResolver {
  String resolveMediaUrl(
    Post post,
    BooruConfigViewer config,
  );

  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  );
}

class DefaultMediaUrlResolver implements MediaUrlResolver {
  const DefaultMediaUrlResolver({
    required this.imageQuality,
  });

  final ImageQuality imageQuality;

  @override
  String resolveMediaUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.isGif
      ? post.sampleImageUrl
      : config.imageDetaisQuality.toOption().fold(
              () => switch (imageQuality) {
                ImageQuality.low => post.thumbnailImageUrl,
                ImageQuality.original =>
                  post.isVideo ? post.videoThumbnailUrl : post.originalImageUrl,
                _ =>
                  post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
              },
              (quality) => switch (stringToGeneralPostQualityType(quality)) {
                GeneralPostQualityType.preview => post.thumbnailImageUrl,
                GeneralPostQualityType.sample =>
                  post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
                GeneralPostQualityType.original =>
                  post.isVideo ? post.videoThumbnailUrl : post.originalImageUrl,
              },
            ) ??
            switch (imageQuality) {
              ImageQuality.low => post.thumbnailImageUrl,
              ImageQuality.original =>
                post.isVideo ? post.videoThumbnailUrl : post.originalImageUrl,
              _ => post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
            };

  @override
  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.videoUrl;
}

class SampleMediaUrlResolver implements MediaUrlResolver {
  const SampleMediaUrlResolver();

  @override
  String resolveMediaUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.sampleImageUrl;

  @override
  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.videoUrl;
}
