import 'package:flutter/painting.dart';

import 'cached_network_avif_image.dart';
import 'dio_extended_image_provider.dart';

ImageProvider networkImageDecoder({
  required DioExtendedNetworkImageProvider source,
  required bool useAvif,
  int? cacheWidth,
  int? cacheHeight,
}) => useAvif
    ? CustomCachedNetworkAvifImageProvider(
        source.url,
        scale: source.scale,
        headers: source.headers,
        cacheManager: source.cacheManager,
        dio: source.dio,
        cancelToken: source.cancelToken,
        fetchStrategy: source.fetchStrategy,
        cacheKey: source.cacheKey,
        cacheMaxAge: source.cacheMaxAge,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      )
    : source;
