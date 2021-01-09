import 'package:boorusama/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/domain/wikis/wiki.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';

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
