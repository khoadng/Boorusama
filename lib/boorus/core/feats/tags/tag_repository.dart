// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  });
}
