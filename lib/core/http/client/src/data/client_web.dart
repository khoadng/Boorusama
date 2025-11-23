// Package imports:
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

HttpClientAdapter newNativeAdapter({String? userAgent}) {
  return IOHttpClientAdapter();
}

void setupHttpOverrides() {
  // No-op on web
}
