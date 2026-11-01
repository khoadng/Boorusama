// Flutter imports:
import 'package:flutter/painting.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/images/booru_image.dart';

void main() {
  final cases = [
    (
      name: 'a tall image covering a square tile decodes at the tile width',
      fit: BoxFit.cover,
      image: const Size(1000, 3000),
      expected: (width: 300, height: null),
    ),
    (
      name: 'a wide image covering a square tile decodes at the tile height',
      fit: BoxFit.cover,
      image: const Size(3000, 1000),
      expected: (width: null, height: 300),
    ),
    (
      name: 'a wide image contained in a square tile decodes at the tile width',
      fit: BoxFit.contain,
      image: const Size(3000, 1000),
      expected: (width: 300, height: null),
    ),
    (
      name:
          'an image of unknown size covering a tile decodes at the tile width',
      fit: BoxFit.cover,
      image: Size.zero,
      expected: (width: 300, height: null),
    ),
  ];

  for (final c in cases) {
    test(c.name, () {
      expect(
        layoutDecodeSize(
          layout: const Size(100, 100),
          pixelRatio: 3,
          fit: c.fit,
          imageWidth: c.image.width,
          imageHeight: c.image.height,
        ),
        c.expected,
      );
    });
  }

  test('an unbounded layout keeps the original resolution', () {
    expect(
      layoutDecodeSize(
        layout: const Size(100, double.infinity),
        pixelRatio: 3,
        fit: BoxFit.cover,
      ),
      isNull,
    );
  });
}
