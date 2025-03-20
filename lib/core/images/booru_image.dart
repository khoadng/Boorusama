// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../configs/ref.dart';
import '../http/http.dart';
import '../http/providers.dart';
import '../info/device_info.dart';
import '../settings/providers.dart';
import '../settings/settings.dart';
import 'providers.dart';

const _defaultRadius = BorderRadius.all(Radius.circular(8));

class BooruImage extends ConsumerWidget {
  const BooruImage({
    required this.imageUrl,
    super.key,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    this.aspectRatio = 1,
    this.imageWidth,
    this.imageHeight,
    this.forceCover = false,
    this.forceFill = false,
    this.forceLoadPlaceholder = false,
    this.gaplessPlayback = false,
    this.placeholderWidget,
    this.controller,
  });

  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadius? borderRadius;
  final BoxFit? fit;
  final double? aspectRatio;
  final double? imageWidth;
  final double? imageHeight;
  final bool forceCover;
  final bool forceFill;
  final bool forceLoadPlaceholder;
  final bool gaplessPlayback;
  final Widget? placeholderWidget;
  final ExtendedImageController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));
    final imageQualitySettings = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageQuality),
    );
    final fallbackAspectRatio = ref.watch(
      imageListingSettingsProvider
          .select((value) => value.imageGridAspectRatio),
    );
    final deviceInfo = ref.watch(deviceInfoProvider);

    return BooruRawImage(
      dio: dio,
      imageUrl: imageUrl,
      placeholderUrl: placeholderUrl,
      borderRadius: borderRadius,
      fit: fit,
      aspectRatio: aspectRatio ?? fallbackAspectRatio,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      forceCover: forceCover,
      forceFill: forceFill,
      isLargeImage: imageQualitySettings != ImageQuality.low,
      forceLoadPlaceholder: forceLoadPlaceholder,
      headers: {
        AppHttpHeaders.userAgentHeader:
            ref.watch(userAgentProvider(config.booruType)),
        ...ref.watch(extraHttpHeaderProvider(config)),
        ...ref.watch(cachedBypassDdosHeadersProvider(config.url)),
      },
      gaplessPlayback: gaplessPlayback,
      placeholderWidget: placeholderWidget,
      controller: controller,
      androidVersion: deviceInfo.androidDeviceInfo?.version.sdkInt,
    );
  }
}

class BooruRawImage extends StatelessWidget {
  const BooruRawImage({
    required this.dio,
    required this.imageUrl,
    super.key,
    this.placeholderUrl,
    this.borderRadius,
    this.fit,
    this.aspectRatio = 1,
    this.imageWidth,
    this.imageHeight,
    this.forceCover = false,
    this.forceFill = false,
    this.headers = const {},
    this.isLargeImage = false,
    this.forceLoadPlaceholder = false,
    this.gaplessPlayback = false,
    this.placeholderWidget,
    this.controller,
    this.androidVersion,
  });

  final Dio dio;
  final String imageUrl;
  final String? placeholderUrl;
  final BorderRadius? borderRadius;
  final BoxFit? fit;
  final double? aspectRatio;
  final double? imageWidth;
  final double? imageHeight;
  final bool forceCover;
  final bool forceFill;
  final Map<String, String> headers;
  final bool isLargeImage;
  final bool forceLoadPlaceholder;
  final bool gaplessPlayback;
  final Widget? placeholderWidget;
  final ExtendedImageController? controller;
  final int? androidVersion;

  @override
  Widget build(BuildContext context) {
    final imagePlaceHolder = ImagePlaceHolder(
      borderRadius: borderRadius ?? _defaultRadius,
    );

    return NullableAspectRatio(
      aspectRatio: forceCover || fit == BoxFit.contain ? null : aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.roundToDouble();
          final height = constraints.maxHeight.roundToDouble();
          final fit = this.fit ??
              // If the image is larger than the layout, just fill it to prevent distortion
              (forceFill &&
                      _shouldForceFill(
                        constraints.biggest,
                        imageWidth,
                        imageHeight,
                      )
                  ? BoxFit.fill
                  // Cover is for the standard grid that crops the image to fit the aspect ratio
                  : forceCover
                      ? BoxFit.cover
                      : BoxFit.contain);
          final borderRadius = this.borderRadius ?? _defaultRadius;

          return imageUrl.isNotEmpty
              ? ExtendedImage.network(
                  imageUrl,
                  dio: dio,
                  headers: headers,
                  borderRadius: borderRadius,
                  width: width,
                  height: height,
                  fit: fit,
                  gaplessPlayback: gaplessPlayback,
                  fetchStrategy: _fetchStrategy,
                  controller: controller,
                  platform: Theme.of(context).platform,
                  androidVersion: androidVersion,
                  placeholderWidget: placeholderWidget ??
                      placeholderUrl.toOption().fold(
                            () => imagePlaceHolder,
                            (url) => Builder(
                              builder: (context) {
                                final hasNetworkPlaceholder =
                                    _shouldLoadPlaceholderUrl(
                                  placeholderUrl: url,
                                  imageUrl: imageUrl,
                                  isLargeImage: isLargeImage,
                                  forceLoadPlaceholder: forceLoadPlaceholder,
                                );

                                return hasNetworkPlaceholder
                                    ? ExtendedImage.network(
                                        url,
                                        dio: dio,
                                        headers: headers,
                                        borderRadius: borderRadius,
                                        width: width,
                                        height: height,
                                        fit: fit,
                                        fetchStrategy: _fetchStrategy,
                                        placeholderWidget: imagePlaceHolder,
                                        platform: Theme.of(context).platform,
                                        androidVersion: androidVersion,
                                      )
                                    : imagePlaceHolder;
                              },
                            ),
                          ),
                  errorWidget: ErrorPlaceholder(
                    borderRadius: borderRadius,
                  ),
                )
              : imagePlaceHolder;
        },
      ),
    );
  }
}

const _fetchStrategy = FetchStrategyBuilder(
  initialPauseBetweenRetries: Duration(milliseconds: 500),
  // Nothing we can do about it, just ignore the error to avoid spamming the logs
  silent: true,
);

bool _shouldLoadPlaceholderUrl({
  required String placeholderUrl,
  required String imageUrl,
  required bool isLargeImage,
  required bool forceLoadPlaceholder,
}) {
  if (forceLoadPlaceholder) return true;

  final placeholder = placeholderUrl;

  // Small image
  if (!isLargeImage) return false;

  // Invalid placeholder URL
  if (placeholder.isEmpty) return false;

  // Same URL, no point in loading the placeholder
  if (placeholder == imageUrl) return false;

  return true;
}

bool _shouldForceFill(
  Size containerSize,
  double? imageWidth,
  double? imageHeight,
) {
  if (imageWidth == null || imageHeight == null) return false;

  if (containerSize.height < imageHeight) return true;
  if (containerSize.width < imageWidth) return true;

  return false;
}

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
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHigh
            .withValues(alpha: 0.5),
        borderRadius: borderRadius ?? _defaultRadius,
      ),
      child: const SizedBox.shrink(),
    );
  }
}

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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
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
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }
}

class NullableAspectRatio extends StatelessWidget {
  const NullableAspectRatio({
    required this.child,
    super.key,
    this.aspectRatio,
  });

  final double? aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return aspectRatio == null
        ? child
        : AspectRatio(
            aspectRatio: aspectRatio!,
            child: child,
          );
  }
}
