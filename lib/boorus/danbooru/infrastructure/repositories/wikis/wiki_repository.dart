// Package imports:
import 'package:flutter_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/wikis/wiki.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';

final wikiProvider =
    Provider<IWikiRepository>((ref) => WikiRepository(ref.watch(apiProvider)));

class WikiRepository implements IWikiRepository {
  final IApi _api;

  WikiRepository(this._api);

  @override
  Future<Wiki> getWikiFor(String title) async =>
      _api.getWiki(title).then((value) {
        try {
          var wiki = Wiki.fromJson(value.response.data);
          return wiki;
        } catch (e) {
          print("Cant parse $title");
        }
      }).catchError((Object obj) {
        throw Exception("Failed to get wiki for $title");
      });
}
