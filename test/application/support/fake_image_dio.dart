import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boorusama/core/http/client/providers.dart';

/// Returns the same small PNG for every requested image URL in widget tests.
Override deterministicImageDioOverride() =>
    dioForWidgetProvider.overrideWith((ref, _) => _fixedImageDio(ref));

/// Serves site favicons, which otherwise reach the network, as a small PNG.
Override deterministicFaviconDioOverride() =>
    faviconDioProvider.overrideWith(_fixedImageDio);

Dio _fixedImageDio(Ref ref) {
  final dio = Dio()..httpClientAdapter = _FixedImageAdapter();
  ref.onDispose(dio.close);
  return dio;
}

final class _FixedImageAdapter implements HttpClientAdapter {
  static final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=',
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(
    _png,
    200,
    headers: const {
      Headers.contentTypeHeader: ['image/png'],
    },
  );

  @override
  void close({bool force = false}) {}
}
