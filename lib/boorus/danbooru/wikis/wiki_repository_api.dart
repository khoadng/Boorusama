// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/wikis/wikis.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

class WikiRepositoryApi implements WikiRepository {
  WikiRepositoryApi(this.client);

  final DanbooruClient client;

  @override
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  }) =>
      client.getWiki(title).then(wikiDtoToWiki).catchError((_) => null);
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
