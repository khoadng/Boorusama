// Dart imports:
import 'dart:isolate';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kRelatedTagLimit = 300;
const _kAITagParams = 'tag,score';

mixin DanbooruClientTags {
  Dio get dio;

  Future<List<TagDto>> getTagsByName({
    int? page,
    bool? hideEmpty,
    required Set<String> tags,
    int limit = 1000,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/tags.json',
      queryParameters: {
        'search[name_comma]': tags.join(','),
        if (page != null) 'page': page,
        if (hideEmpty != null) 'search[hide_empty]': hideEmpty ? 'yes' : 'no',
        'search[order]': 'count',
        'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return Isolate.run(() =>
        (response.data as List).map((item) => TagDto.fromJson(item)).toList());
  }

  Future<RelatedTagDto> getRelatedTag({
    required String query,
    TagCategory? category,
    RelatedType? order,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/related_tag.json',
      queryParameters: {
        'search[query]': query,
        if (category != null) 'search[category]': tagCategoryToString(category),
        if (order != null) 'search[order]': order.name,
        'limit': limit ?? _kRelatedTagLimit,
      },
      cancelToken: cancelToken,
    );

    return Isolate.run(() => RelatedTagDto.fromJson(response.data));
  }

  Future<List<AITagDto>> getAITags({
    required String query,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/ai_tags.json',
      queryParameters: {
        'search[post_tags_match]': query,
        'search[order]': 'score_desc',
        'search[is_posted]': true,
        'only': _kAITagParams,
        if (limit != null) 'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => AITagDto.fromJson(item))
        .toList();
  }
}
