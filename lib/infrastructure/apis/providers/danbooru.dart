import 'package:dio/dio.dart';

class Danbooru {
  final String url = "danbooru.donmai.us";
  final Dio _dio;

  Dio get dio => _dio;

  Danbooru(this._dio) {
    // _dio.interceptors
    //     .add(DioCacheManager(CacheConfig(baseUrl: url)).interceptor);
  }
}
