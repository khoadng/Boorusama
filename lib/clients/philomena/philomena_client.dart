// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

class PhilomenaClient {
  PhilomenaClient({
    Dio? dio,
    required String baseUrl,
    this.apiKey,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
            ));

  final Dio _dio;
  final String? apiKey;

  Future<List<ImageDto>> getImages({
    List<String>? tags,
    int? page,
    int? perPage,
  }) async {
    final response = await _dio.get(
      '/api/v1/json/search/images',
      queryParameters: {
        if (tags != null)
          'q': tags.map((e) => e.replaceAll('_', ' ')).join(','),
        if (page != null && page > 1) 'page': page,
        if (perPage != null) 'per_page': perPage,
        if (apiKey != null) 'key': apiKey,
      },
    );

    final data = response.data['images'];

    return (data as List).map((e) => ImageDto.fromJson(e)).toList();
  }

  Future<List<TagDto>> getTags({
    required String query,
    int? page,
    int? perPage,
  }) async {
    final response = await _dio.get(
      '/api/v1/json/search/tags',
      queryParameters: {
        'q': query.replaceAll('_', ' '),
        if (page != null) 'page': page,
        if (perPage != null) 'per_page': perPage,
        if (apiKey != null) 'key': apiKey,
      },
    );

    final data = response.data['tags'];

    return (data as List).map((e) => TagDto.fromJson(e)).toList();
  }
}
