import 'package:dio/dio.dart';
import 'types/autocomplete_dto.dart';
import 'types/post_dto.dart';
import 'types/search.dart';
import 'types/tag_dto.dart';

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
      '/search/results',
      queryParameters: {
        if (tagIds.isNotEmpty) 'tags': tagIds.join(' '),
        'page': ?switch (page) {
          null => null,
          final p when p > 1 => p,
          _ => null,
        },
      },
    );

    return parsePosts(response.data, baseUrl);
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
    TagType? type,
  }) async {
    final response = await _dio.get(
      '/httpreq.php',
      queryParameters: {
        'mode': 'tag_search',
        'tags': query,
        'type': type?.value ?? TagType.tag.valueStr,
      },
      options: Options(
        responseType: ResponseType.plain,
      ),
    );

    return parseAutocomplete(response.data as String);
  }

  Future<List<PostDto>> getHomePage({
    int? page,
  }) async {
    final response = await _dio.get(
      '/',
      queryParameters: switch (page) {
        null => null,
        final p when p > 1 => {'page': p},
        _ => null,
      },
    );
    return parsePosts(response.data, baseUrl);
  }

  Future<List<int>> getTagIds(
    EshuushuuSearchRequest request,
  ) async {
    if (request.isEmpty) return [];

    final response = await _dio.post(
      '/search/process/',
      data: request.toMap(),
      options: Options(
        followRedirects: false,
        contentType: Headers.formUrlEncodedContentType,
        validateStatus: (status) => status == 303,
      ),
    );

    final location = response.headers.value('location');
    if (location == null) return [];

    // Parse tag IDs from location like: http://e-shuushuu.net/search/results/?tags=7+720+216485
    final uri = Uri.parse(location);
    final tagsParam = uri.queryParameters['tags'];
    if (tagsParam == null) return [];

    return tagsParam
        .split(RegExp(r'[\s,]+'))
        .map((id) => int.tryParse(id.trim()))
        .whereType<int>()
        .toList();
  }
}
