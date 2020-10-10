import 'dart:convert';

import 'package:boorusama/domain/accounts/i_account_repository.dart';
import 'package:boorusama/domain/tags/i_tag_repository.dart';
import 'package:boorusama/domain/tags/tag.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';

class TagRepository implements ITagRepository {
  final Danbooru _api;

  final IAccountRepository _accountRepository;

  TagRepository(this._api, this._accountRepository);

  @override
  Future<List<Tag>> getTagsByNamePattern(String stringPattern, int page) async {
    final account = await _accountRepository.get();
    var uri = Uri.https(_api.url, "/tags.json", {
      "login": account.username,
      "api_key": account.apiKey,
      "page": page.toString(),
      "search[hide_empty]": "yes",
      "search[name_or_alias_matches]": stringPattern + "*",
      "search[order]": "count",
      "limit": "10",
    });

    var respond = await _api.client.get(uri);

    if (respond.statusCode == 200) {
      var content = jsonDecode(respond.body);
      var tags = List<Tag>();
      for (var item in content) {
        try {
          tags.add(Tag.fromJson(item));
        } catch (e) {
          print("Cant parse $item[id]");
        }
      }
      return tags;
      // return content.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception("Unable to perform request!");
    }
  }
}
