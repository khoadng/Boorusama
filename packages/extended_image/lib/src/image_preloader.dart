// Flutter imports:
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:retriable/retriable.dart';

// Project imports:
import 'image_cache_manager.dart';
import 'image_fetcher.dart';

class ImagePreloader {
  const ImagePreloader({
    required this.cacheManager,
    required this.dio,
    this.enableLogging = false,
  });

  final ImageCacheManager cacheManager;
  final Dio dio;
  final bool enableLogging;

  Future<void> preloadImage(
    String url, {
    Map<String, String>? headers,
    FetchStrategyBuilder? fetchStrategy,
    CancellationToken? cancelToken,
    String? customKey,
    Duration? maxAge,
  }) async {
    final cacheKey = customKey ?? cacheManager.generateCacheKey(url);

    // Check if already cached
    final hasValidCacheResult = cacheManager.hasValidCache(
      cacheKey,
      maxAge: maxAge,
    );
    bool hasValidCache;
    if (hasValidCacheResult is Future<bool>) {
      hasValidCache = await hasValidCacheResult;
    } else {
      hasValidCache = hasValidCacheResult;
    }

    if (hasValidCache) {
      _log('Image already cached: $url');
      return;
    }

    try {
      _log('Preloading image: $url');

      final bytes = await ImageFetcher.fetchImageBytes(
        url: url,
        dio: dio,
        headers: headers,
        fetchStrategy: fetchStrategy,
        cancelToken: cancelToken,
        printError: enableLogging,
      );

      await cacheManager.saveFile(cacheKey, bytes);
      _log('Successfully preloaded: $url');
    } catch (e) {
      _log('Failed to preload $url: $e');
      // Don't rethrow - preloading is non-critical
    }
  }

  void _log(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[ImagePreloader] $message');
    }
  }
}
