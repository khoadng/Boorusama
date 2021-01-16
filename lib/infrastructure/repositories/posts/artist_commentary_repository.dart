import 'package:boorusama/domain/posts/artist_commentary.dart';
import 'package:boorusama/domain/posts/i_artist_commentary_repository.dart';
import 'package:boorusama/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:html/parser.dart' as html;

final artistCommentaryProvider = Provider<IArtistCommentaryRepository>(
    (ref) => ArtistCommentaryRepository(ref.watch(apiProvider)));

class ArtistCommentaryRepository implements IArtistCommentaryRepository {
  final IApi _api;

  ArtistCommentaryRepository(this._api);

  @override
  Future<ArtistCommentary> getCommentary(int postId) =>
      _api.getArtistCommentary(postId).then((value) {
        final data = value.response.data.toString();
        final document = html.parse(data);

        final original = document.documentElement
            .querySelector("section[id='original-artist-commentary']")
            // ?.querySelector("div[class='prose ']")
            ?.innerHtml;

        final translated = document.documentElement
            .querySelector("section[id='translated-artist-commentary']")
            // ?.querySelector("div[class='prose ']")
            ?.innerHtml;

        return ArtistCommentary(original: original, translated: translated);
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
