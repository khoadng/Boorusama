import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_artist_commentary_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/cache/artist_commentary_cache.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/cache/artist_commentary_cache_decorator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:html/parser.dart' as html;

final artistCommentaryProvider = Provider<IArtistCommentaryRepository>((ref) {
  final repo = ArtistCommentaryRepository(
      ref.watch(apiProvider), ref.watch(accountProvider));
  final cache = ref.watch(artistCommentaryCacheProvider);
  final endpoint = ref.watch(apiEndpointProvider);
  return ArtistCommentaryCacheDecorator(repo, cache, endpoint);
});

class ArtistCommentaryRepository implements IArtistCommentaryRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  ArtistCommentaryRepository(this._api, this._accountRepository);

  @override
  Future<ArtistCommentary> getCommentary(int postId) async {
    final account = await _accountRepository.get();

    return _api.getPost(account.username, account.apiKey, postId).then((value) {
      final data = value.response.data.toString();
      final Map<String, dynamic> payload = {"data": data};
      final commentary = compute(parseCommentary, payload);

      return commentary;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          throw Exception("Failed to get artist commentary from $postId");
          break;
        default:
      }
      return ArtistCommentary.empty();
    });
  }
}

ArtistCommentary parseCommentary(Map<String, dynamic> data) {
  final htmlString = data["data"];
  final stopwatch = Stopwatch()..start();

  final document = html.parse(htmlString);

  final original = document.documentElement
      .querySelector("section[id='original-artist-commentary']")
      // ?.querySelector("div[class='prose ']")
      ?.innerHtml;

  final translated = document.documentElement
      .querySelector("section[id='translated-artist-commentary']")
      // ?.querySelector("div[class='prose ']")
      ?.innerHtml;
  print('parsed commentary in ${stopwatch.elapsed.inMilliseconds}ms'
      .toUpperCase());
  return ArtistCommentary(original: original, translated: translated);
}
