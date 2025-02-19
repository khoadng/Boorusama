// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'wiki.dart';

abstract class WikiRepository {
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  });
}
