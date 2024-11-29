// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';

// Project imports:
import 'package:boorusama/core/images/dio_extended_image_provider.dart';

class DioExtendedImage extends ExtendedImage {
  DioExtendedImage.network(
    String url, {
    Dio? dio,
    super.key,
    super.semanticLabel,
    super.excludeFromSemantics = false,
    super.width,
    super.height,
    super.color,
    super.opacity,
    super.colorBlendMode,
    super.fit,
    super.alignment = Alignment.center,
    super.repeat = ImageRepeat.noRepeat,
    super.centerSlice,
    super.matchTextDirection = false,
    super.gaplessPlayback = false,
    super.filterQuality = FilterQuality.low,
    super.loadStateChanged,
    super.shape,
    super.border,
    super.borderRadius,
    super.clipBehavior = Clip.antiAlias,
    super.enableLoadState = true,
    super.beforePaintImage,
    super.afterPaintImage,
    super.mode = ExtendedImageMode.none,
    super.enableMemoryCache = true,
    super.clearMemoryCacheIfFailed = true,
    super.onDoubleTap,
    super.initGestureConfigHandler,
    super.enableSlideOutPage = false,
    BoxConstraints? constraints,
    CancellationToken? cancelToken,
    int retries = 3,
    Duration? timeLimit,
    Map<String, String>? headers,
    bool cache = true,
    double scale = 1.0,
    Duration timeRetry = const Duration(milliseconds: 100),
    super.extendedImageEditorKey,
    super.initEditorConfigHandler,
    super.heroBuilderForSlidingPage,
    super.clearMemoryCacheWhenDispose = false,
    super.handleLoadingProgress = false,
    super.extendedImageGestureKey,
    int? cacheWidth,
    int? cacheHeight,
    super.isAntiAlias = false,
    String? cacheKey,
    bool printError = true,
    double? compressionRatio,
    int? maxBytes,
    bool cacheRawData = false,
    String? imageCacheName,
    Duration? cacheMaxAge,
    super.layoutInsets = EdgeInsets.zero,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        assert(constraints == null || constraints.debugAssertIsValid()),
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        super(
          image: ExtendedResizeImage.resizeIfNeeded(
            provider: DioExtendedNetworkImageProvider(
              url,
              dio: dio,
              scale: scale,
              headers: headers,
              cache: cache,
              cancelToken: cancelToken,
              retries: retries,
              timeRetry: timeRetry,
              timeLimit: timeLimit,
              cacheKey: cacheKey,
              printError: printError,
              cacheRawData: cacheRawData,
              imageCacheName: imageCacheName,
              cacheMaxAge: cacheMaxAge,
            ),
            compressionRatio: compressionRatio,
            maxBytes: maxBytes,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            cacheRawData: cacheRawData,
            imageCacheName: imageCacheName,
          ),
          constraints: (width != null || height != null)
              ? constraints?.tighten(width: width, height: height) ??
                  BoxConstraints.tightFor(width: width, height: height)
              : constraints,
        );
}
