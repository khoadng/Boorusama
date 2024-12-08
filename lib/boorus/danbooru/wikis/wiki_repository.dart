// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import 'wiki.dart';

abstract class WikiRepository {
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  });
}

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
