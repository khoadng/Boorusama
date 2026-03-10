// Flutter imports:
import 'package:flutter/widgets.dart';

class TallMediaConfigs {
  const TallMediaConfigs({
    this.aspectRatioThreshold = 2.15,
    this.minHeightPx = 1800,
    this.minViewportHeightRatio = 1.35,
    this.minPixelCount = 2000000,
    this.minScrollExtentPx = 48,
  });

  final double aspectRatioThreshold;
  final double minHeightPx;
  final double minViewportHeightRatio;
  final double minPixelCount;
  final double minScrollExtentPx;
}

class MediaViewportDisposition {
  const MediaViewportDisposition._({
    required this.isTall,
    required this.shouldFitToWidth,
    required this.scrollExtent,
  });

  const MediaViewportDisposition.standard()
    : isTall = false,
      shouldFitToWidth = false,
      scrollExtent = 0;

  factory MediaViewportDisposition.fromViewport({
    required Size viewportSize,
    required double width,
    required double height,
    required bool isVideo,
    TallMediaConfigs configs = const TallMediaConfigs(),
  }) {
    if (width <= 0 || height <= 0 || isVideo) {
      return const MediaViewportDisposition.standard();
    }

    final aspectRatio = height / width;
    final viewportRatio = viewportSize.height > 0
        ? height / viewportSize.height
        : 0.0;
    final pixelCount = width * height;
    final projectedHeight = _projectedHeight(width, height, viewportSize);
    final rawScrollExtent = projectedHeight - viewportSize.height;
    final hasScroll = rawScrollExtent > configs.minScrollExtentPx;

    final meetsAspect = aspectRatio >= configs.aspectRatioThreshold;
    final meetsHeight = height >= configs.minHeightPx;
    final meetsViewport = viewportRatio >= configs.minViewportHeightRatio;
    final meetsPixels = pixelCount >= configs.minPixelCount;

    final isTall =
        hasScroll &&
        ((meetsAspect && meetsViewport) ||
            (meetsAspect && meetsHeight && meetsPixels) ||
            (meetsHeight && meetsViewport && meetsPixels));

    if (!isTall) {
      return const MediaViewportDisposition.standard();
    }

    return MediaViewportDisposition._(
      isTall: true,
      shouldFitToWidth: true,
      scrollExtent: rawScrollExtent > 0 ? rawScrollExtent : 0,
    );
  }

  final bool isTall;
  final bool shouldFitToWidth;
  final double scrollExtent;

  bool get hasScrollableExtent => scrollExtent > 0;

  static double _projectedHeight(
    double width,
    double height,
    Size viewportSize,
  ) {
    final viewportWidth = viewportSize.width;
    if (width <= 0 || height <= 0 || viewportWidth <= 0) return height;

    final scale = viewportWidth / width;
    return height * (scale < 1 ? scale : 1.0);
  }
}
