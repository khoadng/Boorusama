// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image.dart';

final _aspectRatio = [
  ...List<double>.generate(20, (_) => 0.71),
  ...List<double>.generate(6, (_) => 1),
  ...List<double>.generate(5, (_) => 0.75),
  ...List<double>.generate(4, (_) => 0.7),
  ...List<double>.generate(3, (_) => 1.33),
  ...List<double>.generate(3, (_) => 0.72),
  ...List<double>.generate(3, (_) => 0.67),
  ...List<double>.generate(3, (_) => 1.41),
  ...List<double>.generate(2, (_) => 0.8),
  ...List<double>.generate(2, (_) => 0.68),
  ...List<double>.generate(2, (_) => 0.69),
  ...List<double>.generate(2, (_) => 0.73),
  ...List<double>.generate(2, (_) => 1.78),
  ...List<double>.generate(2, (_) => 0.74),
  ...List<double>.generate(2, (_) => 0.77),
  ...List<double>.generate(1, (_) => 0.65),
  ...List<double>.generate(1, (_) => 0.83),
  ...List<double>.generate(1, (_) => 0.63),
  ...List<double>.generate(1, (_) => 0.76),
  ...List<double>.generate(1, (_) => 0.78),
  ...List<double>.generate(1, (_) => 0.66),
  ...List<double>.generate(1, (_) => 0.64),
  ...List<double>.generate(1, (_) => 1.42),
  ...List<double>.generate(1, (_) => 0.56),
  ...List<double>.generate(1, (_) => 0.79),
  ...List<double>.generate(1, (_) => 0.81),
  ...List<double>.generate(1, (_) => 0.62),
  ...List<double>.generate(1, (_) => 0.6),
  ...List<double>.generate(1, (_) => 0.82),
  ...List<double>.generate(1, (_) => 1.25),
  ...List<double>.generate(1, (_) => 0.86),
  ...List<double>.generate(1, (_) => 0.88),
  ...List<double>.generate(1, (_) => 0.61),
  ...List<double>.generate(1, (_) => 0.85),
  ...List<double>.generate(1, (_) => 0.84),
  ...List<double>.generate(1, (_) => 0.89),
  ...List<double>.generate(1, (_) => 1.4),
  ...List<double>.generate(1, (_) => 1.5),
  ...List<double>.generate(1, (_) => 0.59),
  ...List<double>.generate(1, (_) => 0.87),
  ...List<double>.generate(1, (_) => 0.58),
  ...List<double>.generate(1, (_) => 0.9),
  ...List<double>.generate(1, (_) => 1.6),
  ...List<double>.generate(1, (_) => 0.57),
  ...List<double>.generate(1, (_) => 0.91),
  ...List<double>.generate(1, (_) => 0.92),
  ...List<double>.generate(1, (_) => 1.43),
  ...List<double>.generate(1, (_) => 0.93),
  ...List<double>.generate(1, (_) => 0.94),
  ...List<double>.generate(1, (_) => 1.2),
  ...List<double>.generate(1, (_) => 0.95),
  ...List<double>.generate(1, (_) => 0.55),
  ...List<double>.generate(1, (_) => 0.5),
  ...List<double>.generate(1, (_) => 0.96),
];

String getImageUrlForDisplay(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.thumbnailImageUrl;
  if (quality == ImageQuality.low) return post.thumbnailImageUrl;

  return post.sampleImageUrl;
}

Widget createRandomPlaceholderContainer(
  BuildContext context, {
  BorderRadius? borderRadius,
}) {
  return AspectRatio(
    aspectRatio: _aspectRatio[Random().nextInt(_aspectRatio.length - 1)],
    child: const ImagePlaceHolder(),
  );
}
