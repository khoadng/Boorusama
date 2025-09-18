// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../settings/settings.dart';

class TallMediaDisposition {
  const TallMediaDisposition._({
    required this.isTall,
    required this.shouldFitToWidth,
    required this.aspectRatio,
    required this.viewportRatio,
    required this.pixelCount,
    required this.scrollExtent,
  });

  const TallMediaDisposition.standard({
    required double aspectRatio,
    required double viewportRatio,
    required double pixelCount,
  }) : this._(
         isTall: false,
         shouldFitToWidth: false,
         aspectRatio: aspectRatio,
         viewportRatio: viewportRatio,
         pixelCount: pixelCount,
         scrollExtent: 0,
       );

  factory TallMediaDisposition.tall({
    required double aspectRatio,
    required double viewportRatio,
    required double pixelCount,
    required double scrollExtent,
  }) => TallMediaDisposition._(
    isTall: true,
    shouldFitToWidth: true,
    aspectRatio: aspectRatio,
    viewportRatio: viewportRatio,
    pixelCount: pixelCount,
    scrollExtent: scrollExtent,
  );

  final bool isTall;
  final bool shouldFitToWidth;
  final double aspectRatio;
  final double viewportRatio;
  final double pixelCount;
  final double scrollExtent;

  bool get hasScrollableExtent => scrollExtent > 0;
}

TallMediaDisposition classifyTallMedia({
  required TallMediaSettings settings,
  required Size viewportSize,
  required double width,
  required double height,
  required bool isVideo,
}) {
  if (!settings.enabled || width <= 0 || height <= 0 || isVideo) {
    final aspectRatio = width <= 0 || height <= 0 ? 0.0 : height / width;
    final viewportRatio = viewportSize.height == 0
        ? 0.0
        : height / viewportSize.height;
    return TallMediaDisposition.standard(
      aspectRatio: aspectRatio,
      viewportRatio: viewportRatio,
      pixelCount: width * height,
    );
  }

  final aspectRatio = height / width;
  final viewportRatio = viewportSize.height == 0
      ? 0.0
      : height / viewportSize.height;
  final pixelCount = width * height;
  final projectedHeight = _projectedHeight(width, height, viewportSize);
  final rawScrollExtent = projectedHeight - viewportSize.height;
  final hasScroll = rawScrollExtent > TallMediaSettings.minScrollExtentPx;

  final meetsAspect = aspectRatio >= TallMediaSettings.aspectRatioThreshold;
  final meetsHeight = height >= TallMediaSettings.minHeightPx;
  final meetsViewport = viewportRatio >= TallMediaSettings.minViewportHeightRatio;
  final meetsPixels = pixelCount >= TallMediaSettings.minPixelCount;

  final isTall =
      hasScroll &&
      ((meetsAspect && meetsViewport) ||
          (meetsAspect && meetsHeight && meetsPixels) ||
          (meetsHeight && meetsViewport && meetsPixels));

  if (kDebugMode) {
    debugPrint(
      'TallMediaClassifier: aspect=$aspectRatio viewportRatio=$viewportRatio '
      'pixels=$pixelCount projectedHeight=$projectedHeight scroll=$rawScrollExtent '
      '-> isTall=$isTall',
    );
  }

  if (!isTall) {
    return TallMediaDisposition.standard(
      aspectRatio: aspectRatio,
      viewportRatio: viewportRatio,
      pixelCount: pixelCount,
    );
  }

  final scrollExtent = rawScrollExtent > 0 ? rawScrollExtent : 0.0;

  return TallMediaDisposition.tall(
    aspectRatio: aspectRatio,
    viewportRatio: viewportRatio,
    pixelCount: pixelCount,
    scrollExtent: scrollExtent > 0 ? scrollExtent : 0,
  );
}

double _projectedHeight(double width, double height, Size viewportSize) {
  final viewportWidth = viewportSize.width;
  if (width <= 0 || height <= 0 || viewportWidth <= 0) {
    return height;
  }

  final scale = viewportWidth / width;
  final clampedScale = scale < 1 ? scale : 1.0;
  return height * clampedScale;
}
