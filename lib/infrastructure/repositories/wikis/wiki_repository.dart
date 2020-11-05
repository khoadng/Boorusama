import 'package:boorusama/domain/wikis/i_wiki_repository.dart';
import 'package:boorusama/domain/wikis/wiki.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class WikiRepository implements IWikiRepository {
  final Danbooru _api;

  WikiRepository(this._api);

  @override
  Future<Wiki> getWikiFor(String title) async {
    //TODO: should hardcode limit parameter
    var uri = Uri.https(_api.url, "/wiki_pages/$title.json", {});

    var wiki;
    try {
      final respond = await _api.dio
          .get(uri.toString(), options: buildCacheOptions(Duration(days: 7)));

      try {
        wiki = Wiki.fromJson(respond.data);
      } catch (e) {
        print("Cant parse ${respond.data['id']}");
      }
    } on DioError {
      // if (e.response.statusCode == 422) {
      //   throw CannotSearchMoreThanTwoTags(
      //       "You cannot search for more than 2 tags at a time. Upgrade your account to search for more tags at once.");
      // }
    }

    return wiki;
  }
}
