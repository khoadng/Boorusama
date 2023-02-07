// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/core/application/api/api.dart';

class BooruImage extends StatelessWidget {
  const BooruImage({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    required this.aspectRatio,
    this.previewCacheManager,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadius? borderRadius;
  final BoxFit? fit;
  final double aspectRatio;
  final CacheManager? previewCacheManager;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: CachedNetworkImage(
          httpHeaders: const {
            'User-Agent': userAgent,
          },
          fit: fit ?? BoxFit.fill,
          imageUrl: imageUrl,
          placeholder: (context, url) => placeholderUrl != null
              ? CachedNetworkImage(
                  httpHeaders: const {
                    'User-Agent': userAgent,
                  },
                  fit: fit ?? BoxFit.fill,
                  imageUrl: placeholderUrl!,
                  cacheManager: previewCacheManager,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (context, url) => ImagePlaceHolder(
                    borderRadius: borderRadius ??
                        const BorderRadius.all(Radius.circular(8)),
                  ),
                )
              : ImagePlaceHolder(
                  borderRadius: borderRadius ??
                      const BorderRadius.all(Radius.circular(8)),
                ),
          errorWidget: (context, url, error) => ErrorPlaceholder(
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(8)),
          ),
          fadeInDuration: const Duration(microseconds: 200),
          fadeOutDuration: const Duration(microseconds: 500),
        ),
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ImagePlaceHolder extends StatelessWidget {
  const ImagePlaceHolder({
    super.key,
    this.borderRadius,
  });

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.25,
            vertical: constraints.maxHeight * 0.25,
          ),
        ),
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ErrorPlaceholder extends StatelessWidget {
  const ErrorPlaceholder({
    super.key,
    this.borderRadius,
  });

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.25,
            vertical: constraints.maxHeight * 0.25,
          ),
          child: Image.asset(
            'assets/images/error.png',
            color: Theme.of(context).colorScheme.background.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
