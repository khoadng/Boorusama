// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/nullable_aspect_ratio.dart';
import 'package:boorusama/widgets/widgets.dart';

const _defaultRadius = BorderRadius.all(Radius.circular(8));

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
      return _EmptyImage(
        borderRadius: borderRadius,
        forceFill: forceFill,
        aspectRatio: aspectRatio,
      );
    }

    return forceFill
        ? _builForceFillImage(ref, config)
        : _builderNormalImage(ref, config);
  }

  Widget _builderNormalImage(WidgetRef ref, BooruConfig config) {
    return NullableAspectRatio(
      aspectRatio: aspectRatio,
      child: ExtendedImage.network(
        imageUrl,
        width: width,
        height: height,
        cacheHeight: cacheHeight,
        cacheWidth: cacheWidth,
        headers: _getHeaders(config, ref),
        shape: BoxShape.rectangle,
        cacheMaxAge: kDefaultImageCacheDuration,
        borderRadius: borderRadius ?? _defaultRadius,
        fit: fit ?? BoxFit.fill,
        loadStateChanged: (state) => _buildImageState(state, ref, config),
      ),
    );
  }

  Widget _builForceFillImage(WidgetRef ref, BooruConfig config) {
    return Column(
      children: [
        Expanded(
          child: ExtendedImage.network(
            imageUrl,
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            headers: _getHeaders(config, ref),
            cacheHeight: cacheHeight,
            cacheWidth: cacheWidth,
            shape: BoxShape.rectangle,
            cacheMaxAge: kDefaultImageCacheDuration,
            borderRadius: borderRadius ?? _defaultRadius,
            fit: BoxFit.cover,
            loadStateChanged: (state) => _buildImageState(state, ref, config),
          ),
        ),
      ],
    );
  }

  Widget? _buildImageState(
    ExtendedImageState state,
    WidgetRef ref,
    BooruConfig config,
  ) =>
      switch (state.extendedImageLoadState) {
        LoadState.loading => placeholderUrl.toOption().fold(
              () => ImagePlaceHolder(
                borderRadius: borderRadius ?? _defaultRadius,
              ),
              (url) => url.isNotBlank()
                  ? ExtendedImage.network(
                      url,
                      width: width ?? double.infinity,
                      height: height ?? double.infinity,
                      cacheHeight: cacheHeight,
                      cacheWidth: cacheWidth,
                      shape: BoxShape.rectangle,
                      cacheMaxAge: kDefaultImageCacheDuration,
                      fit: BoxFit.cover,
                      borderRadius: borderRadius ?? _defaultRadius,
                      loadStateChanged: (state) =>
                          state.extendedImageLoadState == LoadState.loading
                              ? ImagePlaceHolder(
                                  borderRadius: borderRadius ?? _defaultRadius,
                                )
                              : null,
                      headers: _getHeaders(config, ref),
                    )
                  : ImagePlaceHolder(
                      borderRadius: borderRadius ?? _defaultRadius,
                    ),
            ),
        LoadState.failed => ErrorPlaceholder(
            borderRadius: borderRadius ?? _defaultRadius,
          ),
        LoadState.completed => null,
      };

  Map<String, String> _getHeaders(BooruConfig config, WidgetRef ref) => {
        AppHttpHeaders.userAgentHeader:
            ref.watch(userAgentGeneratorProvider(config)).generate(),
        ...ref.watch(extraHttpHeaderProvider(config)),
      };
}

class _EmptyImage extends StatelessWidget {
  const _EmptyImage({
    required this.borderRadius,
    required this.forceFill,
    this.aspectRatio,
  });

  final BorderRadiusGeometry? borderRadius;
  final bool forceFill;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final placeholder = ImagePlaceHolder(
      borderRadius: borderRadius ?? _defaultRadius,
    );

    return forceFill
        ? Column(
            children: [
              Expanded(
                child: placeholder,
              )
            ],
          )
        : NullableAspectRatio(
            aspectRatio: aspectRatio,
            child: placeholder,
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
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh.applyOpacity(0.5),
        borderRadius: borderRadius ?? _defaultRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => const SizedBox.shrink(),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: borderRadius ?? _defaultRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.25,
            vertical: constraints.maxHeight * 0.25,
          ),
          child: Image.asset(
            'assets/images/error.png',
            color: context.colorScheme.surface.applyOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
