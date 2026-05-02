import 'dart:math' as math;

import 'package:dio/dio.dart';

import 'nozomi_memory_cache.dart';
import 'nozomi_post_index.dart';
import 'nozomi_tag_index.dart';
import 'types/types.dart';

const _kNozomiUrl = 'https://nozomi.la';
const _kNozomiContentUrl = 'https://j.gold-usergeneratedcontent.net';
const _kDefaultPageLimit = 64;
const _kMaxPageLimit = 100;

class NozomiClient {
  NozomiClient({
    Dio? dio,
    String? baseUrl,
    NozomiMemoryCache<List<int>>? indexCache,
    NozomiMemoryCache<Map<String, int>>? searchIndexCache,
    this.logger,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? _kNozomiUrl,
               headers: {
                 'Origin': _kNozomiUrl,
                 'Referer': '$_kNozomiUrl/',
               },
             ),
           ) {
    _tagIndex = NozomiTagIndex(
      dio: _dio,
      bucketCache: searchIndexCache,
    );
    _postIndex = NozomiPostIndex(
      dio: _dio,
      indexCache: indexCache,
    );
  }

  final Dio _dio;
  late final NozomiPostIndex _postIndex;
  late final NozomiTagIndex _tagIndex;
  final void Function(String message)? logger;

  Future<List<NozomiAutocompleteDto>> getAutocomplete({
    required String query,
    int limit = 25,
  }) => _tagIndex.autocomplete(query: query, limit: limit);

  Future<NozomiTagCountLookup> resolveTagCounts(Iterable<String> tags) {
    return _tagIndex.resolveCounts(tags);
  }

  Future<Map<String, int>> getTagCounts(Iterable<String> tags) async {
    return (await resolveTagCounts(tags)).counts;
  }

  Future<List<NozomiPostDto>> getPosts({
    List<String>? tags,
    int page = 1,
    int? limit,
    NozomiPostOrder order = NozomiPostOrder.date,
  }) async {
    final result = await getPostsWithTotal(
      tags: tags,
      page: page,
      limit: limit,
      order: order,
    );

    return result.posts;
  }

  Future<({List<NozomiPostDto> posts, int? total})> getPostsWithTotal({
    List<String>? tags,
    int page = 1,
    int? limit,
    NozomiPostOrder order = NozomiPostOrder.date,
  }) async {
    final pageLimit = _pageLimit(limit);
    final result = await getPostIdsWithTotal(
      tags: tags ?? const [],
      page: page,
      limit: pageLimit,
      order: order,
    );

    final posts = await Future.wait(
      result.ids.take(pageLimit).map((id) => getPost(id: id)),
    );

    return (posts: posts.nonNulls.toList(), total: result.total);
  }

  Future<NozomiPostDto?> getPost({
    required int id,
  }) async {
    final response = await _dio.get(
      '$_kNozomiContentUrl/post/${NozomiPath.dataPath(id)}.json',
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if ((response.statusCode ?? 0) >= 400) {
      logger?.call('Skipping Nozomi post $id: ${response.statusCode}');

      return null;
    }

    if (response.data case final Map data) {
      return NozomiPostDto.fromJson(data);
    }

    return null;
  }

  Future<List<int>> getPostIds({
    List<String> tags = const [],
    int page = 1,
    int? limit,
    NozomiPostOrder order = NozomiPostOrder.date,
  }) => _postIndex.getPostIds(
    tags: tags,
    page: page,
    limit: _pageLimit(limit),
    order: order,
  );

  Future<({List<int> ids, int? total})> getPostIdsWithTotal({
    List<String> tags = const [],
    int page = 1,
    int? limit,
    NozomiPostOrder order = NozomiPostOrder.date,
  }) => _postIndex.getPostIdsResult(
    tags: tags,
    page: page,
    limit: _pageLimit(limit),
    order: order,
  );
}

int _pageLimit(int? limit) {
  return math.min(
    math.max(limit ?? _kDefaultPageLimit, 1),
    _kMaxPageLimit,
  );
}
