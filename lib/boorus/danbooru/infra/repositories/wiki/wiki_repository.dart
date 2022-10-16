// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wikis.dart';
import 'package:boorusama/core/infra/http_parser.dart';

class WikiRepository implements IWikiRepository {
  WikiRepository(Api api) : _api = api;
  final Api _api;

  @override
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  }) =>
      _api
          .getWiki(title, cancelToken: cancelToken)
          .then(extractData)
          .then(WikiDto.fromJson)
          .then(wikiDtoToWiki)
          .catchError((_) => null);
}
