// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/nullable_aspect_ratio.dart';
import 'package:boorusama/widgets/widgets.dart';

class BooruImage extends ConsumerWidget {
  const BooruImage({
    super.key,
    required this.imageUrl,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    this.aspectRatio = 1,
    this.cacheHeight,
    this.cacheWidth,
    this.forceFill = false,
    this.width,
    this.height,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadius? borderRadius;
  final BoxFit? fit;
  final double? aspectRatio;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool forceFill;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    if (imageUrl.isEmpty) {
      return forceFill
          ? Column(
              children: [
                Expanded(
                  child: ImagePlaceHolder(
                    borderRadius: borderRadius ??
                        const BorderRadius.all(Radius.circular(8)),
                  ),
                )
              ],
            )
          : NullableAspectRatio(
              aspectRatio: aspectRatio,
              child: ImagePlaceHolder(
                borderRadius:
                    borderRadius ?? const BorderRadius.all(Radius.circular(8)),
              ),
            );
    }

    return forceFill
        ? _builForceFillImage(ref, config)
        : _builderNormalImage(ref, config);
  }

  Widget _builderNormalImage(WidgetRef ref, BooruConfig config) {
    if (aspectRatio == null) {
      return ExtendedImage.network(
        imageUrl,
        width: width,
        height: height,
        cacheHeight: cacheHeight,
        cacheWidth: cacheWidth,
        headers: {
          'User-Agent':
              ref.watch(userAgentGeneratorProvider(config)).generate(),
        },
        shape: BoxShape.rectangle,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
        fit: fit ?? BoxFit.fill,
        loadStateChanged: (state) =>
            state.extendedImageLoadState == LoadState.loading
                ? ImagePlaceHolder(
                    borderRadius: borderRadius ??
                        const BorderRadius.all(Radius.circular(8)),
                  )
                : null,
      );
    } else {
      return NullableAspectRatio(
        aspectRatio: aspectRatio,
        child: ExtendedImage.network(
          imageUrl,
          width: width,
          height: height,
          cacheHeight: cacheHeight,
          cacheWidth: cacheWidth,
          headers: {
            'User-Agent':
                ref.watch(userAgentGeneratorProvider(config)).generate(),
          },
          shape: BoxShape.rectangle,
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(4)),
          fit: fit ?? BoxFit.fill,
          loadStateChanged: _buildImageState,
        ),
      );
    }
  }

  Widget _builForceFillImage(WidgetRef ref, BooruConfig config) {
    return Column(
      children: [
        Expanded(
          child: ExtendedImage.network(
            imageUrl,
            headers: {
              'User-Agent':
                  ref.watch(userAgentGeneratorProvider(config)).generate(),
            },
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            cacheHeight: cacheHeight,
            cacheWidth: cacheWidth,
            shape: BoxShape.rectangle,
            fit: BoxFit.cover,
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(4)),
            loadStateChanged: _buildImageState,
          ),
        ),
      ],
    );
  }

  Widget? _buildImageState(ExtendedImageState state) =>
      switch (state.extendedImageLoadState) {
        LoadState.loading => placeholderUrl.toOption().fold(
              () => ImagePlaceHolder(
                borderRadius:
                    borderRadius ?? const BorderRadius.all(Radius.circular(8)),
              ),
              (url) => url.isNotBlank()
                  ? ExtendedImage.network(
                      url,
                      width: width ?? double.infinity,
                      height: height ?? double.infinity,
                      cacheHeight: cacheHeight,
                      cacheWidth: cacheWidth,
                      shape: BoxShape.rectangle,
                      fit: BoxFit.cover,
                      borderRadius: borderRadius ??
                          const BorderRadius.all(Radius.circular(4)),
                      loadStateChanged: (state) => state
                                  .extendedImageLoadState ==
                              LoadState.loading
                          ? ImagePlaceHolder(
                              borderRadius: borderRadius ??
                                  const BorderRadius.all(Radius.circular(8)),
                            )
                          : null,
                    )
                  : ImagePlaceHolder(
                      borderRadius: borderRadius ??
                          const BorderRadius.all(Radius.circular(8)),
                    ),
            ),
        LoadState.failed => ErrorPlaceholder(
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(8)),
          ),
        LoadState.completed => null,
      };
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
        color: context.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Container(),
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
        color: context.colorScheme.surfaceVariant,
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
            color: context.colorScheme.surface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
