// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTagsByName(
    Set<String> tags,
    int page, {
    CancelToken? cancelToken,
  });
}
