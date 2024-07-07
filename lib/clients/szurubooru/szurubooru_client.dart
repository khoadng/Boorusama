// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'szurubooru_client_comments.dart';
import 'szurubooru_client_favorites.dart';
import 'szurubooru_client_posts.dart';
import 'types/types.dart';

String _encodeAuthHeader(String username, String token) =>
    base64Encode(utf8.encode('$username:$token'));

class SzurubooruClient
    with
        SzurubooruClientComments,
        SzurubooruClientFavorites,
        SzurubooruClientPosts {
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

  @override
  Dio get dio => _dio;

  Future<List<TagDto>> autocomplete({
    required String query,
    int limit = 15,
  }) async {
    final q = query.length < 3 ? '$query*' : '*$query*';

    final response = await _dio.get(
      '/api/tags',
      queryParameters: {
        'query': [
          q,
          'sort:usages',
        ].join(' '),
        'limit': limit,
      },
    );

    final results = response.data['results'] as List;

    return results.map((e) => TagDto.fromJson(e)).toList();
  }

  Future<List<TagCategoryDto>> getTagCategories() async {
    final response = await _dio.get(
      '/api/tag-categories',
    );

    final results = response.data['results'] as List;

    return results.map((e) => TagCategoryDto.fromJson(e)).toList();
  }
}
