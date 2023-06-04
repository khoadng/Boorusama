// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/features/wikis/wikis.dart';
import 'package:boorusama/foundation/networks/networks.dart';

class WikiRepositoryApi implements WikiRepository {
  WikiRepositoryApi(DanbooruApi api) : _api = api;
  final DanbooruApi _api;

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

Wiki? wikiDtoToWiki(WikiDto d) {
  try {
    return Wiki(
      body: d.body!,
      id: d.id!,
      title: d.title!,
      otherNames: List<String>.of(d.otherNames!),
    );
  } catch (e) {
    return null;
  }
}
