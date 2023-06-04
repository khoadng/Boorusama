// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feat/wikis/models/wiki.dart';

abstract class WikiRepository {
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  });
}
