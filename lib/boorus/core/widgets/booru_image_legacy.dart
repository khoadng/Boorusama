// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';

class BooruImageLegacy extends ConsumerWidget {
  const BooruImageLegacy({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    this.cacheHeight,
    this.cacheWidth,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return ImagePlaceHolder(
        width: cacheWidth,
        height: cacheHeight,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: CachedNetworkImage(
        httpHeaders: {
          'User-Agent': ref.watch(userAgentGeneratorProvider).generate(),
        },
        width: cacheWidth?.toDouble(),
        height: cacheHeight?.toDouble(),
        imageUrl: imageUrl,
        errorListener: (e) => {},
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) =>
            placeholderUrl != null && placeholderUrl!.isNotEmpty
                ? CachedNetworkImage(
                    httpHeaders: {
                      'User-Agent':
                          ref.watch(userAgentGeneratorProvider).generate(),
                    },
                    errorListener: (e) => {},
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    imageUrl: placeholderUrl!,
                    fit: fit ?? BoxFit.cover,
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
    );
  }
}
