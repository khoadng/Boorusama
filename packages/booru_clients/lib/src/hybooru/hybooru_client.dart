// Package imports:
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

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

const _kDefaultPageSize = 20;

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
      pageSize: _parsePageSize(data['pageSize']),
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
      pageSize: _parsePageSize(data['pageSize']),
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

  Future<List<TagDto>> getTagsFromPostId({required int postId}) async {
    final crawlerDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        headers: _dio.options.headers,
      ),
    );

    try {
      final response = await crawlerDio.get('/posts/$postId');
      final html = parse(response.data);

      // Find the script element containing the JSON data
      final scriptElement = html.querySelector('script#initialData');
      if (scriptElement == null) return [];

      final jsonText = scriptElement.text;
      if (jsonText.isEmpty) return [];

      final jsonData = json.decode(jsonText) as Map<String, dynamic>;
      final post = jsonData['post'] as Map<String, dynamic>?;
      if (post == null) return [];

      final tags = post['tags'] as Map<String, dynamic>?;
      if (tags == null) return [];

      return tags.entries
          .map((entry) => TagDto.fromJson(entry.key, entry.value as int))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

int _parsePageSize(dynamic pageSize) {
  return switch (pageSize) {
    int size => size,
    String size => int.tryParse(size) ?? _kDefaultPageSize,
    _ => _kDefaultPageSize,
  };
}
