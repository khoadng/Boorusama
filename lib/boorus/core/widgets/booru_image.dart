// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';

class BooruImage extends ConsumerWidget {
  const BooruImage({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    this.aspectRatio = 1,
    this.previewCacheManager,
    this.cacheHeight,
    this.cacheWidth,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;
  final double aspectRatio;
  final CacheManager? previewCacheManager;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: _Empty(borderRadius: borderRadius),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: CachedNetworkImage(
            httpHeaders: {
              'User-Agent': ref.watch(userAgentGeneratorProvider).generate(),
            },
            errorListener: (e) {},
            memCacheWidth: cacheWidth,
            memCacheHeight: cacheHeight,
            fit: fit ?? BoxFit.fill,
            imageUrl: imageUrl,
            placeholder: (context, url) =>
                placeholderUrl != null && placeholderUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        httpHeaders: {
                          'User-Agent':
                              ref.watch(userAgentGeneratorProvider).generate(),
                        },
                        errorListener: (e) {},
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
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.borderRadius,
  });

  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ImagePlaceHolder(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ImagePlaceHolder extends StatelessWidget {
  const ImagePlaceHolder({
    super.key,
    this.borderRadius,
    this.width,
    this.height,
  });

  final BorderRadiusGeometry? borderRadius;
  final int? width;
  final int? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.toDouble(),
      height: height?.toDouble(),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
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

  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
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
            color: context.colorScheme.background.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
