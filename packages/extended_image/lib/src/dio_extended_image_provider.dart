// Dart imports:
import 'dart:async';
import 'dart:ui' as ui show Codec;

// Flutter imports:
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:retriable/retriable.dart';

import 'image_cache_manager.dart';

class DioExtendedNetworkImageProvider
    extends ImageProvider<ExtendedNetworkImageProvider>
    with ExtendedImageProvider<ExtendedNetworkImageProvider>
    implements ExtendedNetworkImageProvider {
  /// Creates an object that fetches the image at the given URL.
  DioExtendedNetworkImageProvider(
    this.url, {
    required this.dio,
    this.scale = 1.0,
    this.headers,
    this.cache = false,
    this.cacheKey,
    this.printError = true,
    this.cacheRawData = false,
    this.cancelToken,
    this.imageCacheName,
    this.cacheMaxAge,
    this.fetchStrategy,
    this.cacheManager,
  });

  /// The [Dio] client that'll be used to make image fetch requests.
  final Dio dio;

  /// The name of [ImageCache], you can define custom [ImageCache] to store this provider.
  @override
  final String? imageCacheName;

  /// Whether cache raw data if you need to get raw data directly.
  /// For example, we need raw image data to edit,
  /// but [ui.Image.toByteData()] is very slow. So we cache the image
  /// data here.
  @override
  final bool cacheRawData;

  /// Whether cache image to local
  @override
  final bool cache;

  /// The URL from which the image will be fetched.
  @override
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  @override
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  @override
  final Map<String, String>? headers;

  /// The token to cancel network request
  @override
  final CancellationToken? cancelToken;

  /// Custom cache key
  @override
  final String? cacheKey;

  /// print error
  @override
  final bool printError;

  /// The max duration to cahce image.
  /// After this time the cache is expired and the image is reloaded.
  @override
  final Duration? cacheMaxAge;

  final FetchStrategyBuilder? fetchStrategy;

  /// Custom cache manager for caching images
  final ImageCacheManager? cacheManager;

  @override
  int get retries => fetchStrategy?.maxAttempts ?? 3;

  @override
  Duration get timeRetry =>
      fetchStrategy?.initialPauseBetweenRetries ??
      const Duration(milliseconds: 100);

  @override
  Duration? get timeLimit => fetchStrategy?.timeout;

  @override
  ImageStreamCompleter loadImage(
    ExtendedNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(
        key,
        chunkEvents,
        decode,
      ),
      scale: key.scale,
      chunkEvents: chunkEvents.stream,
      debugLabel: key.url,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<ExtendedNetworkImageProvider>('Image key', key),
        ];
      },
    );
  }

  @override
  Future<ExtendedNetworkImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<ExtendedNetworkImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(
    ExtendedNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    assert(
      key == this,
      'The key provided to obtainKey must be the same key that was used to obtain this ImageStreamCompleter',
    );

    final bytes = await _fetchImageBytes(chunkEvents);
    if (bytes == null) {
      return Future<ui.Codec>.error(StateError('Failed to load $url.'));
    }

    return instantiateImageCodec(bytes, decode);
  }

  /// Get an effective cache manager, creating a default one if none is provided
  ImageCacheManager _getEffectiveCacheManager() {
    return cacheManager ??
        DefaultImageCacheManager(
          cacheDirName: cacheImageFolderName,
          enableLogging: printError && kDebugMode,
        );
  }

  /// Gets the image bytes, either from cache or network
  Future<Uint8List?> _fetchImageBytes(
    StreamController<ImageChunkEvent>? chunkEvents,
  ) async {
    // Skip caching if disabled
    if (!cache) {
      return await _loadNetwork(chunkEvents);
    }

    final manager = _getEffectiveCacheManager();
    final effectiveCacheKey =
        manager.generateCacheKey(url, customKey: cacheKey);

    final hasValidCache = await manager.hasValidCache(
      effectiveCacheKey,
      maxAge: cacheMaxAge,
    );

    // Try to load from cache
    if (hasValidCache) {
      final cachedData = await manager.getCachedFileBytes(effectiveCacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData;
      }
    }

    // Load from network if not in cache
    final networkData = await _loadNetwork(chunkEvents);
    if (networkData != null && networkData.isNotEmpty) {
      await manager.saveFile(effectiveCacheKey, networkData);
    }

    return networkData;
  }

  /// Get the image from network
  Future<Uint8List?> _loadNetwork(
    StreamController<ImageChunkEvent>? chunkEvents,
  ) async {
    try {
      final resolved = Uri.base.resolve(url);

      final response = await tryGetResponse<List<int>>(
        resolved,
        dio: dio,
        cancelToken: cancelToken,
        fetchStrategy: fetchStrategy,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
        onReceiveProgress: chunkEvents != null
            ? (count, total) {
                if (!chunkEvents.isClosed && total >= 0) {
                  chunkEvents.add(
                    ImageChunkEvent(
                      cumulativeBytesLoaded: count,
                      expectedTotalBytes: total,
                    ),
                  );
                }
              }
            : null,
      );

      if (response == null || response.data == null) {
        return null;
      }

      final bytes = Uint8List.fromList(response.data!);
      if (bytes.lengthInBytes == 0) {
        return Future<Uint8List>.error(
          StateError('NetworkImage is an empty file: $resolved'),
        );
      }

      return bytes;
    } on OperationCanceledError catch (_) {
      _print('User cancel request $url.');
      return Future<Uint8List>.error(StateError('User cancel request $url.'));
    } catch (e) {
      _print(e);
    } finally {
      await chunkEvents?.close();
    }
    return null;
  }

  @override
  Future<Uint8List?> getNetworkImageData({
    StreamController<ImageChunkEvent>? chunkEvents,
  }) async {
    return _fetchImageBytes(chunkEvents);
  }

  void _print(Object error) {
    if (printError && kDebugMode) {
      debugPrint('[DioExtendedImageProvider] $error');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DioExtendedNetworkImageProvider &&
        url == other.url &&
        scale == other.scale &&
        cacheRawData == other.cacheRawData &&
        timeLimit == other.timeLimit &&
        fetchStrategy == other.fetchStrategy &&
        cancelToken == other.cancelToken &&
        cache == other.cache &&
        cacheKey == other.cacheKey &&
        imageCacheName == other.imageCacheName &&
        cacheMaxAge == other.cacheMaxAge;
  }

  @override
  int get hashCode => Object.hash(
        url,
        scale,
        cacheRawData,
        timeLimit,
        fetchStrategy,
        cancelToken,
        cache,
        cacheKey,
        imageCacheName,
        cacheMaxAge,
      );

  @override
  String toString() => 'DioExtendedNetworkImageProvider("$url", scale: $scale)';
}
