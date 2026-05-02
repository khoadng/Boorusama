// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../images/types.dart';
import '../../../post/types.dart';

abstract class MediaUrlResolver {
  String resolveMediaUrl(
    Post post,
    BooruConfigViewer config,
  );

  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  );

  double? resolveMediaAspectRatio(
    Post post,
    BooruConfigViewer config,
  );

  double? resolveVideoAspectRatio(
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
  double? resolveMediaAspectRatio(
    Post post,
    BooruConfigViewer config,
  ) => post.isGif
      ? post.effectiveSampleAspectRatio
      : config.imageDetaisQuality.toOption().fold(
              () => switch (imageQuality) {
                ImageQuality.low => post.effectiveThumbnailAspectRatio,
                ImageQuality.original =>
                  post.isVideo
                      ? post.effectiveVideoThumbnailAspectRatio
                      : post.effectiveOriginalAspectRatio,
                _ =>
                  post.isVideo
                      ? post.effectiveVideoThumbnailAspectRatio
                      : post.effectiveSampleAspectRatio,
              },
              (quality) => switch (stringToGeneralPostQualityType(quality)) {
                GeneralPostQualityType.preview =>
                  post.effectiveThumbnailAspectRatio,
                GeneralPostQualityType.sample =>
                  post.isVideo
                      ? post.effectiveVideoThumbnailAspectRatio
                      : post.effectiveSampleAspectRatio,
                GeneralPostQualityType.original =>
                  post.isVideo
                      ? post.effectiveVideoThumbnailAspectRatio
                      : post.effectiveOriginalAspectRatio,
              },
            ) ??
            switch (imageQuality) {
              ImageQuality.low => post.effectiveThumbnailAspectRatio,
              ImageQuality.original =>
                post.isVideo
                    ? post.effectiveVideoThumbnailAspectRatio
                    : post.effectiveOriginalAspectRatio,
              _ =>
                post.isVideo
                    ? post.effectiveVideoThumbnailAspectRatio
                    : post.effectiveSampleAspectRatio,
            };

  @override
  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.videoUrl;

  @override
  double? resolveVideoAspectRatio(
    Post post,
    BooruConfigViewer config,
  ) => post.effectiveVideoAspectRatio;
}

class SampleMediaUrlResolver implements MediaUrlResolver {
  const SampleMediaUrlResolver();

  @override
  String resolveMediaUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.sampleImageUrl;

  @override
  double? resolveMediaAspectRatio(
    Post post,
    BooruConfigViewer config,
  ) => post.effectiveSampleAspectRatio;

  @override
  String resolveVideoUrl(
    Post post,
    BooruConfigViewer config,
  ) => post.videoUrl;

  @override
  double? resolveVideoAspectRatio(
    Post post,
    BooruConfigViewer config,
  ) => post.effectiveVideoAspectRatio;
}
