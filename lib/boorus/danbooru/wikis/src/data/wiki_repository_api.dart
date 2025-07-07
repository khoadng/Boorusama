// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../types/wiki.dart';
import '../types/wiki_repository.dart';
import 'converter.dart';

class WikiRepositoryApi implements WikiRepository {
  WikiRepositoryApi(this.client);

  final DanbooruClient client;

  @override
  Future<Wiki?> getWikiFor(
    String title, {
    CancelToken? cancelToken,
  }) => client.getWiki(title).then(wikiDtoToWiki).catchError((_) => null);
}
