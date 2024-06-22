// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

// Project imports:
import 'gelbooru_client_favorites.dart';
import 'types/post_v1_dto.dart';

class GelbooruV1Client with GelbooruClientFavorites {
  GelbooruV1Client({
    required String baseUrl,
    this.passHash,
    this.userId,
    Map<String, String>? headers,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: headers ?? {},
            ));

  final Dio _dio;

  @override
  final String? passHash;

  @override
  final String? userId;

  @override
  Dio get dio => _dio;

  Future<List<PostV1Dto>> getPosts({
    int? page,
    List<String>? tags,
  }) async {
    final tagString = tags == null || tags.isEmpty ? 'all' : tags.join('+');

    final response = await _dio.get(
      '/index.php',
      queryParameters: {
        'page': 'post',
        's': 'list',
        'tags': tagString,
        if (page != null) 'pid': (page - 1) * 20,
      },
    );

    final document = parse(response.data);
    final data = document.getElementsByClassName('thumb');

    return data.map((e) => PostV1Dto.fromHTML(e)).toList();
  }
}
