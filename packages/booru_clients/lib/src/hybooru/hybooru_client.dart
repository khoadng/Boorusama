// packages/booru_clients/lib/src/hybooru/hybooru_client.dart
// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

typedef HybooruPosts = ({
  List<PostSummaryDto> posts,
  int? total,
  int? pageSize,
});

typedef HybooruTags = ({
  dynamic tags, // Map<String, int> when !full, List<AutocompleteDto> when full
  int? total,
  int? pageSize,
});

class HybooruClient {
  HybooruClient({
    Dio? dio,
    required String baseUrl,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
            ));

  final Dio _dio;

  Future<HybooruPosts> getPosts({
    String? query,
    int? page,
    int? pageSize,
    bool? hashes,
    bool? blurhash,
  }) async {
    final response = await _dio.get(
      '/api/post',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
        if (hashes != null) 'hashes': hashes,
        if (blurhash != null) 'blurhash': blurhash,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final posts = (data['posts'] as List<dynamic>?)
            ?.map((e) => PostSummaryDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return (
      posts: posts,
      total: data['total'] as int?,
      pageSize: data['pageSize'] as int?,
    );
  }

  Future<PostDto?> getPost({
    required int id,
  }) async {
    try {
      final response = await _dio.get('/api/post/$id');
      return PostDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<HybooruTags> getTags({
    String? query,
    String? sorting, // "used" or "id"
    int? page,
    int? pageSize,
    bool? full,
  }) async {
    final response = await _dio.get(
      '/api/tags',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (sorting != null) 'sorting': sorting,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
        if (full != null) 'full': full,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final tags = data['tags'];

    return (
      tags: tags,
      total: data['total'] as int?,
      pageSize: data['pageSize'] as int?,
    );
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
    int? pageSize,
  }) async {
    if (query.isEmpty) return [];

    try {
      // Wrap query in wildcards for partial matching like Hybooru expects
      final wildcardQuery = '*$query*';

      final result = await getTags(
        query: wildcardQuery,
        full: true,
        pageSize: pageSize ?? 20,
      );

      if (result.tags is List) {
        // Full format - array of TagSummary objects
        return (result.tags as List)
            .map((e) => AutocompleteDto.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (result.tags is Map) {
        // Simple format - map of tag names to post counts
        return (result.tags as Map<String, dynamic>)
            .entries
            .map((e) => AutocompleteDto(
                  name: e.key,
                  posts: e.value as int?,
                  parents: null,
                  siblings: null,
                ))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
