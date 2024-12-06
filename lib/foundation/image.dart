// Flutter imports:
import 'package:flutter/widgets.dart';

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
