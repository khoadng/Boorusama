// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

String _encodeAuthHeader(String username, String token) =>
    base64Encode(utf8.encode('$username:$token'));

class SzurubooruClient {
  SzurubooruClient({
    Dio? dio,
    required String baseUrl,
    Map<String, dynamic>? headers,
    String? username,
    String? token,
  }) {
    _dio = dio ?? Dio();

    final h = headers != null ? {...headers} : <String, dynamic>{};

    h['Content-Type'] = 'application/json';
    h['Accept'] = 'application/json';

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: h,
    );

    if (username != null && token != null) {
      _dio.options.headers['Authorization'] =
          'Token ${_encodeAuthHeader(username, token)}';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  late Dio _dio;

  Future<List<PostDto>> getPosts({
    int? limit,
    int? offset,
    String? query,
  }) async {
    final response = await _dio.get(
      '/api/posts',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'query': query,
      },
    );

    final results = response.data['results'] as List;

    return results
        .map((e) => PostDto.fromJson(
              e,
              baseUrl: _dio.options.baseUrl,
            ))
        .toList();
  }

  Future<List<TagDto>> autocomplete({
    required String query,
    int limit = 15,
  }) async {
    final response = await _dio.get(
      '/api/tags',
      queryParameters: {
        'query': '*$query* sort:usages',
        'limit': limit,
      },
    );

    final results = response.data['results'] as List;

    return results.map((e) => TagDto.fromJson(e)).toList();
  }
}
