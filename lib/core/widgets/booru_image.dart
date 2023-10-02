// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
        ? Column(
            children: [
              Expanded(
                child: ExtendedImage.network(
                  imageUrl,
                  width: width ?? double.infinity,
                  height: height ?? double.infinity,
                  shape: BoxShape.rectangle,
                  fit: BoxFit.cover,
                  borderRadius: borderRadius ??
                      const BorderRadius.all(Radius.circular(4)),
                  loadStateChanged: (state) =>
                      state.extendedImageLoadState == LoadState.loading
                          ? NullableAspectRatio(
                              aspectRatio: aspectRatio,
                              child: ImagePlaceHolder(
                                borderRadius: borderRadius ??
                                    const BorderRadius.all(Radius.circular(8)),
                              ),
                            )
                          : null,
                ),
              ),
            ],
          )
        : ConditionalParentWidget(
            condition: aspectRatio == null,
            conditionalBuilder: (child) => Center(
              child: NullableAspectRatio(
                aspectRatio: aspectRatio,
                child: child,
              ),
            ),
            child: NullableAspectRatio(
              aspectRatio: aspectRatio,
              child: ExtendedImage.network(
                imageUrl,
                width: width,
                height: height,
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
        builder: (context, constraints) => Container(),
      ),
    );
  }
}

class ImagePlaceHolder2 extends StatelessWidget {
  const ImagePlaceHolder2({
    super.key,
    this.borderRadius,
  });

  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
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
