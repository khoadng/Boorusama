// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'types/types.dart';

class Shimmie2Client {
  Shimmie2Client({
    Dio? dio,
    required String baseUrl,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
            ));

  final Dio _dio;

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final isEmpty = tags?.join(' ').isEmpty ?? true;

    final response = await _dio.get(
      '/api/danbooru/find_posts/index.xml',
      queryParameters: {
        if (!isEmpty) 'tags': tags?.join(' '),
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return _parsePosts(response);
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    if (query.isEmpty) return [];

    final response = await _dio.get(
      '/api/internal/autocomplete',
      queryParameters: {
        's': query,
      },
    );

    return (response.data as Map<String, dynamic>)
        .entries
        .map((e) => AutocompleteDto(
              value: e.key,
              count: e.value,
            ))
        .toList();
  }
}

FutureOr<List<PostDto>> _parsePosts(value) {
  final dtos = <PostDto>[];
  final xmlDocument = XmlDocument.parse(value.data);
  final posts = xmlDocument.findAllElements('tag');
  for (final item in posts) {
    dtos.add(PostDto.fromXml(item));
  }
  return dtos;
}
