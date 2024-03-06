// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

class EmptyTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async =>
      [];
}
