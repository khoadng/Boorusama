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
    int? page,
    List<String>? tags,
  }) async {
    final response = await _dio.get(
      '/api/posts',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (page != null && page > 0) 'offset': (page - 1) * (limit ?? 100),
        if (tags != null && tags.isNotEmpty) 'query': tags.join(' '),
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

  Future<List<CommentDto>> getComments({
    required int postId,
  }) async {
    final response = await _dio.get(
      '/api/comments',
      queryParameters: {
        'query': 'post:$postId',
      },
    );

    final results = response.data['results'] as List;

    return results.map((e) => CommentDto.fromJson(e)).toList();
  }

  Future<PostDto> addToFavorites({
    required int postId,
  }) async {
    final response = await _dio.post(
      '/api/post/$postId/favorite',
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: _dio.options.baseUrl,
    );
  }

  Future<PostDto> removeFromFavorites({
    required int postId,
  }) async {
    final response = await _dio.delete(
      '/api/post/$postId/favorite',
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: _dio.options.baseUrl,
    );
  }

  Future<List<TagCategoryDto>> getTagCategories() async {
    final response = await _dio.get(
      '/api/tag-categories',
    );

    final results = response.data['results'] as List;

    return results.map((e) => TagCategoryDto.fromJson(e)).toList();
  }
}
