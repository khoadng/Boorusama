// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/ui/interactive_booru_image.dart';

class SwipeTargetImage extends StatelessWidget {
  const SwipeTargetImage({
    super.key,
    required this.aspectRatio,
    required this.imageUrl,
  });

  final double aspectRatio;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return InteractiveBooruImage(
      useHero: false,
      heroTag: "",
      aspectRatio: aspectRatio,
      imageUrl: imageUrl,
      placeholderImageUrl: imageUrl,
    );
  }
}
