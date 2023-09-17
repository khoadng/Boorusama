// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';

class EmptyTagRepository implements TagRepository {
  @override
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async =>
      [];
}
