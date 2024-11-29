// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/dio_extended_image.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
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
    final dio = ref.watch(dioProvider(config));

    return BooruRawImage(
      dio: dio,
      imageUrl: imageUrl,
      placeholderUrl: placeholderUrl,
      borderRadius: borderRadius,
      fit: fit,
      aspectRatio: aspectRatio,
      cacheHeight: cacheHeight,
      cacheWidth: cacheWidth,
      forceFill: forceFill,
      width: width,
      height: height,
      headers: {
        AppHttpHeaders.userAgentHeader:
            ref.watch(userAgentProvider(config.booruType)),
        ...ref.watch(extraHttpHeaderProvider(config)),
      },
    );
  }
}

class BooruRawImage extends StatelessWidget {
  const BooruRawImage({
    super.key,
    required this.dio,
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
    this.headers = const {},
  });

  final Dio dio;
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
  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _EmptyImage(
        borderRadius: borderRadius,
        forceFill: forceFill,
        aspectRatio: aspectRatio,
      );
    }

    return forceFill ? _builForceFillImage() : _builderNormalImage();
  }

  Widget _builderNormalImage() {
    return NullableAspectRatio(
      aspectRatio: aspectRatio,
      child: DioExtendedImage.network(
        imageUrl,
        dio: dio,
        width: width,
        height: height,
        cacheHeight: cacheHeight,
        cacheWidth: cacheWidth,
        headers: headers,
        shape: BoxShape.rectangle,
        cacheMaxAge: kDefaultImageCacheDuration,
        borderRadius: borderRadius ?? _defaultRadius,
        fit: fit ?? BoxFit.fill,
        loadStateChanged: (state) => aspectRatio != null
            ? _buildImageState(state)
            : state.extendedImageLoadState == LoadState.loading
                ? ImagePlaceHolder(
                    borderRadius: borderRadius ?? _defaultRadius,
                  )
                : null,
      ),
    );
  }

  Widget _builForceFillImage() {
    return Column(
      children: [
        Expanded(
          child: DioExtendedImage.network(
            imageUrl,
            dio: dio,
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            headers: headers,
            cacheHeight: cacheHeight,
            cacheWidth: cacheWidth,
            shape: BoxShape.rectangle,
            cacheMaxAge: kDefaultImageCacheDuration,
            borderRadius: borderRadius ?? _defaultRadius,
            fit: BoxFit.cover,
            loadStateChanged: (state) => _buildImageState(state),
          ),
        ),
      ],
    );
  }

  Widget? _buildImageState(
    ExtendedImageState state,
  ) =>
      switch (state.extendedImageLoadState) {
        LoadState.loading => placeholderUrl.toOption().fold(
              () => ImagePlaceHolder(
                borderRadius: borderRadius ?? _defaultRadius,
              ),
              (url) => url.isNotEmpty
                  ? DioExtendedImage.network(
                      url,
                      dio: dio,
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
                      headers: headers,
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
        color: context.colorScheme.surfaceContainerLow,
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
            color: context.colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
