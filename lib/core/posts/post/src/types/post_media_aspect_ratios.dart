// Project imports:
import 'post.dart';

abstract interface class PostMediaAspectRatios {
  double? get thumbnailAspectRatio;
  double? get sampleAspectRatio;
  double? get originalAspectRatio;
  double? get videoThumbnailAspectRatio;
  double? get videoAspectRatio;
}

extension PostMediaAspectRatioX on Post {
  PostMediaAspectRatios? get _mediaAspectRatios =>
      this is PostMediaAspectRatios ? this as PostMediaAspectRatios : null;

  double? get effectiveThumbnailAspectRatio =>
      _mediaAspectRatios?.thumbnailAspectRatio ?? aspectRatio;

  double? get effectiveSampleAspectRatio =>
      _mediaAspectRatios?.sampleAspectRatio ?? aspectRatio;

  double? get effectiveOriginalAspectRatio =>
      _mediaAspectRatios?.originalAspectRatio ?? aspectRatio;

  double? get effectiveVideoThumbnailAspectRatio =>
      _mediaAspectRatios?.videoThumbnailAspectRatio ?? aspectRatio;

  double? get effectiveVideoAspectRatio =>
      _mediaAspectRatios?.videoAspectRatio ?? aspectRatio;
}
