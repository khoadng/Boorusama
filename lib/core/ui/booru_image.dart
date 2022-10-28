// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

class BooruImage extends StatelessWidget {
  const BooruImage({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    required this.aspectRatio,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: CachedNetworkImage(
          fit: fit ?? BoxFit.fill,
          imageUrl: imageUrl,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? const BorderRadius.all(Radius.circular(8)),
              color: Theme.of(context).cardColor,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              borderRadius:
                  borderRadius ?? const BorderRadius.all(Radius.circular(8)),
              color: Theme.of(context).cardColor,
            ),
            child: const Center(child: Icon(Icons.broken_image_rounded)),
          ),
          fadeInDuration: const Duration(microseconds: 10),
          fadeOutDuration: const Duration(microseconds: 500),
        ),
      ),
    );
  }
}
