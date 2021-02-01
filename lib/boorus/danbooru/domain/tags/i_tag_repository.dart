// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';

abstract class ITagRepository {
  Future<List<Tag>> getTagsByNamePattern(String stringPattern, int page);
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken cancelToken,
  });
}
