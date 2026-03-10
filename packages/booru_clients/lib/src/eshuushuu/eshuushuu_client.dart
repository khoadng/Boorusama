import 'package:dio/dio.dart';
import 'types/autocomplete_dto.dart';
import 'types/post_dto.dart';

class EShuushuuClient {
  EShuushuuClient({
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://e-shuushuu.net'));

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  Future<List<PostDto>> getPosts({
    required List<int> tagIds,
    int? page,
  }) async {
    final response = await _dio.get(
      '/api/v1/images',
      queryParameters: {
        if (tagIds.isNotEmpty) 'tags': tagIds.join('+'),
        if (page != null && page > 1) 'page': page,
      },
    );

    return _parseApiResponse(response.data);
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/api/v1/tags/',
      queryParameters: {
        'search': query,
        'limit': limit,
      },
    );

    return parseAutocompleteFromApi(response.data);
  }

  Future<List<PostDto>> getHomePage({
    int? page,
  }) async {
    final response = await _dio.get(
      '/api/v1/images',
      queryParameters: {
        if (page != null && page > 1) 'page': page,
      },
    );

    return _parseApiResponse(response.data);
  }

  Future<List<int>> resolveTagIds(List<String> tagNames) async {
    final ids = <int>[];
    for (final name in tagNames) {
      final response = await _dio.get(
        '/api/v1/tags/',
        queryParameters: {
          'search': name,
          'limit': 1,
        },
      );

      final results = parseAutocompleteFromApi(response.data);
      if (results.isNotEmpty && results.first.tagId != null) {
        ids.add(results.first.tagId!);
      }
    }
    return ids;
  }

  List<PostDto> _parseApiResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return [];

    final images = data['images'] as List?;
    if (images == null) return [];

    return images
        .whereType<Map<String, dynamic>>()
        .map((json) => PostDto.fromJson(json))
        .toList();
  }
}
