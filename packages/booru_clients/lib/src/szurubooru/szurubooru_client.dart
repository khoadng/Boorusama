// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'szurubooru_client_comments.dart';
import 'szurubooru_client_favorites.dart';
import 'szurubooru_client_pools.dart';
import 'szurubooru_client_posts.dart';
import 'types/types.dart';

String _encodeAuthHeader(String username, String token) =>
    base64Encode(utf8.encode('$username:$token'));

String _normalizeBaseUrl(String baseUrl) {
  final trimmed = baseUrl.trim();
  return trimmed.endsWith('/') ? trimmed : '$trimmed/';
}

String _trimTrailingSlash(String baseUrl) {
  final trimmed = baseUrl.trim();
  return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
}

class SzurubooruClient
    with
        SzurubooruClientComments,
        SzurubooruClientFavorites,
        SzurubooruClientPools,
        SzurubooruClientPosts {
  SzurubooruClient({
    Dio? dio,
    required String baseUrl,
    Map<String, dynamic>? headers,
    String? username,
    String? token,
  }) {
    _dio = dio ?? Dio();
    _mediaBaseUrl = _trimTrailingSlash(baseUrl);

    final h = headers != null ? {...headers} : <String, dynamic>{};

    h['Content-Type'] = 'application/json';
    h['Accept'] = 'application/json';

    _dio.options = BaseOptions(
      baseUrl: _normalizeBaseUrl(baseUrl),
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
  late String _mediaBaseUrl;

  @override
  Dio get dio => _dio;

  @override
  String get baseUrl => _mediaBaseUrl;

  // Only a single global autocomplete request per client is allowed for now
  CancelToken? _autocompleteCancelToken;

  Future<List<TagDto>> autocomplete({
    required String query,
    int limit = 15,
  }) async {
    _autocompleteCancelToken?.cancel('Cancelled due to new request being made');
    _autocompleteCancelToken = CancelToken();

    try {
      final q = query.length < 3 ? '$query*' : '*$query*';

      final response = await _dio.get(
        'api/tags',
        queryParameters: {
          'query': [
            q,
            'sort:usages',
          ].join(' '),
          'limit': limit,
        },
        cancelToken: _autocompleteCancelToken,
      );

      final results = response.data['results'] as List;

      return results.map((e) => TagDto.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return [];
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // Too slow, return empty list, don't throw
        return [];
      }
      rethrow;
    }
  }

  Future<List<TagCategoryDto>> getTagCategories() async {
    final response = await _dio.get(
      'api/tag-categories',
    );

    final results = response.data['results'] as List;

    return results.map((e) => TagCategoryDto.fromJson(e)).toList();
  }
}
