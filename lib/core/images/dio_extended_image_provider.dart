// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Codec;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../http/http.dart';

class DioExtendedNetworkImageProvider
    extends ImageProvider<ExtendedNetworkImageProvider>
    with ExtendedImageProvider<ExtendedNetworkImageProvider>
    implements ExtendedNetworkImageProvider {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  DioExtendedNetworkImageProvider(
    this.url, {
    this.dio,
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
  });

  /// The [Dio] client that'll be used to make image fetch requests.
  final Dio? dio;

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

  @override
  ImageStreamCompleter loadImage(
    ExtendedNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

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
    assert(key == this);
    final String md5Key = cacheKey ?? keyToMd5(key.url);
    ui.Codec? result;
    if (cache) {
      try {
        final Uint8List? data = await _loadCache(
          key,
          chunkEvents,
          md5Key,
        );
        if (data != null) {
          result = await instantiateImageCodec(data, decode);
        }
      } catch (e) {
        if (printError) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }

    if (result == null) {
      try {
        final Uint8List? data = await _loadNetwork(
          key,
          chunkEvents,
        );
        if (data != null) {
          result = await instantiateImageCodec(data, decode);
        }
      } catch (e) {
        if (printError) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }

    //Failed to load
    if (result == null) {
      return Future<ui.Codec>.error(StateError('Failed to load $url.'));
    }

    return result;
  }

  /// Get the image from cache folder.
  Future<Uint8List?> _loadCache(
    ExtendedNetworkImageProvider key,
    StreamController<ImageChunkEvent>? chunkEvents,
    String md5Key,
  ) async {
    final Directory cacheImagesDirectory = Directory(
      join((await getTemporaryDirectory()).path, cacheImageFolderName),
    );
    Uint8List? data;
    // exist, try to find cache image file
    if (cacheImagesDirectory.existsSync()) {
      final File cacheFlie = File(join(cacheImagesDirectory.path, md5Key));
      if (cacheFlie.existsSync()) {
        if (key.cacheMaxAge != null) {
          final DateTime now = DateTime.now();
          final FileStat fs = cacheFlie.statSync();
          if (now.subtract(key.cacheMaxAge!).isAfter(fs.changed)) {
            await cacheFlie.delete(recursive: true);
          } else {
            data = await cacheFlie.readAsBytes();
          }
        } else {
          data = await cacheFlie.readAsBytes();
        }
      }
    }
    // create folder
    else {
      await cacheImagesDirectory.create();
    }
    // load from network
    if (data == null) {
      data = await _loadNetwork(
        key,
        chunkEvents,
      );
      if (data != null) {
        // cache image file
        await File(join(cacheImagesDirectory.path, md5Key)).writeAsBytes(data);
      }
    }

    return data;
  }

  /// Get the image from network.
  Future<Uint8List?> _loadNetwork(
    ExtendedNetworkImageProvider key,
    StreamController<ImageChunkEvent>? chunkEvents,
  ) async {
    try {
      final Uri resolved = Uri.base.resolve(key.url);
      final Response<List<int>>? response =
          await _tryGetResponse(resolved, chunkEvents);
      if (response == null || response.data == null) {
        return null;
      }

      final Uint8List bytes = Uint8List.fromList(response.data!);
      if (bytes.lengthInBytes == 0) {
        return Future<Uint8List>.error(
          StateError('NetworkImage is an empty file: $resolved'),
        );
      }

      return bytes;
    } on OperationCanceledError catch (_) {
      if (printError) {
        if (kDebugMode) {
          print('User cancel request $url.');
        }
      }
      return Future<Uint8List>.error(StateError('User cancel request $url.'));
    } catch (e) {
      if (printError) {
        if (kDebugMode) {
          print(e);
        }
      }
      // [ExtendedImage.clearMemoryCacheIfFailed] can clear cache
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      // scheduleMicrotask(() {
      //   PaintingBinding.instance.imageCache.evict(key);
      // });
      // rethrow;
    } finally {
      await chunkEvents?.close();
    }
    return null;
  }

  // Http get with cancel, delay try again
  Future<Response<List<int>>?> _tryGetResponse(
    Uri resolved,
    StreamController<ImageChunkEvent>? chunkEvents,
  ) async {
    cancelToken?.throwIfCancellationRequested();
    return RetryHelper.tryRun<Response<List<int>>>(
      () async {
        return CancellationTokenSource.register(
          cancelToken,
          (dio ?? globalDio).getUri<List<int>>(
            resolved,
            options: Options(
              responseType: ResponseType.bytes,
              headers: headers,
              receiveTimeout: timeLimit,
              validateStatus: (status) => status == HttpStatus.ok,
            ),
            onReceiveProgress: chunkEvents != null
                ? (count, total) {
                    // Only add event if controller is not closed
                    if (!chunkEvents.isClosed) {
                      chunkEvents.add(
                        ImageChunkEvent(
                          cumulativeBytesLoaded: count,
                          expectedTotalBytes: total,
                        ),
                      );
                    }
                  }
                : null,
          ),
        );
      },
      cancelToken: cancelToken,
      timeRetry: timeRetry,
      retries: retries,
    );
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
        //headers == other.headers &&
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
        //headers,
        retries,
        imageCacheName,
        cacheMaxAge,
      );

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';

  @override

  /// Get network image data from cached
  Future<Uint8List?> getNetworkImageData({
    StreamController<ImageChunkEvent>? chunkEvents,
  }) async {
    final String uId = cacheKey ?? keyToMd5(url);

    if (cache) {
      return _loadCache(
        this,
        chunkEvents,
        uId,
      );
    }

    return _loadNetwork(
      this,
      chunkEvents,
    );
  }

  static final Dio globalDio = Dio()..httpClientAdapter = newNativeAdapter();
}
