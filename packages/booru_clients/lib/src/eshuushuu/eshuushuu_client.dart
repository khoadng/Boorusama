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
    int? limit,
  }) async {
    final response = await _dio.get(
      '/search/results',
      queryParameters: {
        if (tagIds.isNotEmpty) 'tags': tagIds.join(' '),
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
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

  final Map<EshuushuuSearchRequest, List<int>> _tagIdCache = {};

  Future<List<PostDto>> search(
    EshuushuuSearchRequest request, {
    int? page,
  }) async {
    final queryParameters = switch (page) {
      null => null,
      final p when p > 1 => {
        'page': p,
      },
      _ => null,
    };

    if (request.isEmpty) {
      final response = await _dio.get(
        '/',
        queryParameters: queryParameters,
      );
      return parsePosts(response.data, baseUrl);
    }

    final tagIds = await (_tagIdCache.containsKey(request)
        ? Future.value(_tagIdCache[request]!)
        : getTagIds(request).then((map) {
            final ids = [
              ...?map['tags'],
              ...?map['source'],
              ...?map['char'],
              ...?map['artist'],
            ];
            _tagIdCache[request] = ids;
            return ids;
          }));

    if (tagIds.isEmpty) {
      return [];
    }

    return getPosts(
      tagIds: tagIds,
      page: page,
    );
  }

  Future<Map<String, List<int>>> getTagIds(
    EshuushuuSearchRequest request,
  ) async {
    if (request.isEmpty) return {};

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
    if (location == null) return {};

    // Parse tag IDs from location like: http://e-shuushuu.net/search/results/?tags=7+720+216485
    final uri = Uri.parse(location);
    final tagsParam = uri.queryParameters['tags'];
    if (tagsParam == null) return {};

    final ids = tagsParam
        .split(RegExp(r'[\s,]+'))
        .map((id) => int.tryParse(id.trim()))
        .whereType<int>()
        .toList();

    final result = <String, List<int>>{};
    var index = 0;

    for (final (key, count) in request.filterCounts) {
      if (count > 0 && index < ids.length) {
        final end = (index + count).clamp(0, ids.length);
        result[key] = ids.sublist(index, end);
        index = end;
      }
    }

    return result;
  }
}
