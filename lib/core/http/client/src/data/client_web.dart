// Package imports:
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

HttpClientAdapter newNativeAdapter({String? userAgent}) {
  return IOHttpClientAdapter();
}

HttpClientAdapter newWinHttpAdapter({String? userAgent}) {
  throw UnsupportedError('WinHTTP is only available on Windows');
}

void setupHttpOverrides() {
  // No-op on web
}
