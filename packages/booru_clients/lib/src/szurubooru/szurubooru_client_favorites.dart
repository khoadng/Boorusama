// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin SzurubooruClientFavorites {
  Dio get dio;

  Future<PostDto> addToFavorites({
    required int postId,
  }) async {
    final response = await dio.post(
      '/api/post/$postId/favorite',
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: dio.options.baseUrl,
    );
  }

  Future<PostDto> removeFromFavorites({
    required int postId,
  }) async {
    final response = await dio.delete(
      '/api/post/$postId/favorite',
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: dio.options.baseUrl,
    );
  }
}
