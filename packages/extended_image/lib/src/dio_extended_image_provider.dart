// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Codec;

// Flutter imports:
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'retry_utils.dart';

class DioExtendedNetworkImageProvider
    extends ImageProvider<ExtendedNetworkImageProvider>
    with ExtendedImageProvider<ExtendedNetworkImageProvider>
    implements ExtendedNetworkImageProvider {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  DioExtendedNetworkImageProvider(
    this.url, {
    required this.dio,
    this.scale = 1.0,
    this.headers,
    this.cache = false,
    this.retries = 3,
    this.timeLimit,
    this.timeRetry = const Duration(milliseconds: 100),
    this.cacheKey,
    this.printError = true,
    this.cacheRawData = false,
    this.cancelToken,
    this.imageCacheName,
    this.cacheMaxAge,
    this.fetchStrategy,
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

  /// The time limit to request image
  @override
  final Duration? timeLimit;

  /// The time to retry to request
  @override
  final int retries;

  /// The time duration to retry to request
  @override
  final Duration timeRetry;

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

  final FetchStrategy? fetchStrategy;

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

  /// Reads image bytes following these steps:
  ///  1. If caching is enabled, try to read from disk (using _loadCache).
  ///  2. If not found, retrieve from network (using _loadNetwork).
  ///  3. If caching is enabled and network returned data, write it to disk.
  Future<Uint8List?> _fetchImageBytes(
    StreamController<ImageChunkEvent>? chunkEvents,
  ) async {
    final uId = cacheKey ?? keyToMd5(url);
    Uint8List? data;

    if (cache) {
      data = await _loadCache(this, chunkEvents, uId);
      if (data != null) return data;
    }

    // Fallback: load from network.
    data = await _loadNetwork(this, chunkEvents);
    if (data != null && cache) {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, uId));
      try {
        await cacheFile.writeAsBytes(data);
      } catch (e) {
        _print('Failed to write cache: $e');

        return null;
      }
    }
    return data;
  }

  /// Get the image from cache folder.
  Future<Uint8List?> _loadCache(
    ExtendedNetworkImageProvider key,
    StreamController<ImageChunkEvent>? chunkEvents,
    String md5Key,
  ) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, md5Key));

      if (cacheFile.existsSync()) {
        if (key.cacheMaxAge != null) {
          final now = DateTime.now();
          final fs = cacheFile.statSync();
          if (now.subtract(key.cacheMaxAge!).isAfter(fs.modified)) {
            await cacheFile.delete(recursive: true);
          } else {
            return await cacheFile.readAsBytes();
          }
        } else {
          return await cacheFile.readAsBytes();
        }
      }
    } catch (e) {
      _print('Error reading cache: $e');
    }
    return null;
  }

  /// Get the image from network.
  Future<Uint8List?> _loadNetwork(
    ExtendedNetworkImageProvider key,
    StreamController<ImageChunkEvent>? chunkEvents,
  ) async {
    try {
      final resolved = Uri.base.resolve(key.url);

      final response = await tryGetResponse(
        resolved,
        chunkEvents,
        dio: dio,
        headers: headers,
        cancelToken: cancelToken,
        fetchStrategy: fetchStrategy,
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

  Directory? tempDir;

  Future<Directory> _getTempDir() async {
    tempDir ??= await getTemporaryDirectory();

    return tempDir!;
  }

  Future<Directory> _getCacheDirectory() async {
    final cacheDir = Directory(
      join((await _getTempDir()).path, cacheImageFolderName),
    );
    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  void _print(Object error) {
    if (printError) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ExtendedNetworkImageProvider &&
        url == other.url &&
        scale == other.scale &&
        cacheRawData == other.cacheRawData &&
        timeLimit == other.timeLimit &&
        cancelToken == other.cancelToken &&
        timeRetry == other.timeRetry &&
        cache == other.cache &&
        cacheKey == other.cacheKey &&
        retries == other.retries &&
        imageCacheName == other.imageCacheName &&
        cacheMaxAge == other.cacheMaxAge;
  }

  @override
  int get hashCode => Object.hash(
        url,
        scale,
        cacheRawData,
        timeLimit,
        cancelToken,
        timeRetry,
        cache,
        cacheKey,
        retries,
        imageCacheName,
        cacheMaxAge,
      );

  @override
  String toString() => 'DioExtendedNetworkImageProvider("$url", scale: $scale)';
}
