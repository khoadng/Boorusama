// Flutter imports:
import 'package:flutter/material.dart';

mixin ImageInfoMixin {
  double get width;
  double get height;

  double? get aspectRatio => width <= 0 || height <= 0 ? null : width / height;
  double get mpixels => width * height / 1000000;
}

extension ImageExtension on BuildContext {
  int? cacheSize(double num) {
    if (num.isInfinite) return null;

    return (num * MediaQuery.devicePixelRatioOf(this)).round();
  }

  // Not sure how correct this is, so I'm commenting it out for now
  (double? width, double? height, int? cacheWidth, int? cacheHeight)
      sizeFromConstraints(
    BoxConstraints constraints,
    double? aspectRatio,
  ) {
    // final width = constraints.maxWidth.isInfinite ? null : constraints.maxWidth;
    // final height =
    //     constraints.maxHeight.isInfinite ? null : constraints.maxHeight;

    // final (cachedWith, cachedHeight) = calculateCacheSize(
    //   width,
    //   height,
    //   aspectRatio,
    // );

    // return (width, height, cachedWith, cachedHeight);
    return (null, null, null, null);
  }

  (int? width, int? height) calculateCacheSize(
    double? width,
    double? height,
    double? aspectRatio,
  ) {
    if (aspectRatio == null) {
      return (null, null);
    }

    int? cacheWidth;
    int? cacheHeight;

    // if landscape  calculate cache size based on height
    if (aspectRatio > 1) {
      cacheHeight = height == null ? null : cacheSize(height);
    } else {
      cacheWidth = width == null ? null : cacheSize(width);
    }

    return (cacheWidth, cacheHeight);
  }
}
