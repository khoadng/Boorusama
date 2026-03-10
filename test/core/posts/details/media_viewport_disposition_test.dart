// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/posts/details/src/utils/media_viewport_disposition.dart';

void main() {
  final cases = [
    (
      name: 'marks extremely tall images as tall',
      width: 1200.0,
      height: 4200.0,
      viewport: const Size(1080, 1920),
      isVideo: false,
      expectedTall: true,
      expectedFitWidth: true,
    ),
    (
      name: 'does not mark marginal aspect ratios as tall',
      width: 900.0,
      height: 1500.0,
      viewport: const Size(1080, 1920),
      isVideo: false,
      expectedTall: false,
      expectedFitWidth: false,
    ),
    (
      name: 'requires sufficient pixel density',
      width: 420.0,
      height: 1600.0,
      viewport: const Size(720, 1280),
      isVideo: false,
      expectedTall: false,
      expectedFitWidth: false,
    ),
    (
      name: 'ignores tall originals when scaled height fits viewport',
      width: 4200.0,
      height: 2800.0,
      viewport: const Size(1080, 1920),
      isVideo: false,
      expectedTall: false,
      expectedFitWidth: false,
    ),
    (
      name: 'videos are never classified as tall',
      width: 1080.0,
      height: 3600.0,
      viewport: const Size(1080, 1920),
      isVideo: true,
      expectedTall: false,
      expectedFitWidth: false,
    ),
    (
      name: 'zero dimensions produce standard disposition',
      width: 0.0,
      height: 0.0,
      viewport: const Size(1080, 1920),
      isVideo: false,
      expectedTall: false,
      expectedFitWidth: false,
    ),
  ];

  for (final c in cases) {
    test(c.name, () {
      final disposition = MediaViewportDisposition.fromViewport(
        viewportSize: c.viewport,
        width: c.width,
        height: c.height,
        isVideo: c.isVideo,
      );

      expect(disposition.isTall, c.expectedTall);
      expect(disposition.shouldFitToWidth, c.expectedFitWidth);
    });
  }
}
