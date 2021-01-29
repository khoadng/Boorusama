// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:html/parser.dart' as html;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_detail_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_detail.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';

final postDetailProvider = Provider<IPostDetailRepository>((ref) {
  return PostDetailRepository(
      ref.watch(apiProvider), ref.watch(accountProvider));
});

class PostDetailRepository implements IPostDetailRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  PostDetailRepository(this._api, this._accountRepository);

  @override
  Future<PostDetail> getDetails(int postId) async {
    final account = await _accountRepository.get();

    return _api.getPost(account.username, account.apiKey, postId).then((value) {
      final data = value.response.data.toString();
      final Map<String, dynamic> payload = {"data": data, "postId": postId};
      final detail = compute(parseDetails, payload);

      return detail;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          throw Exception("Failed to get detail from $postId");
          break;
        default:
      }
      return PostDetail.empty();
    });
  }
}

PostDetail parseDetails(Map<String, dynamic> data) {
  final htmlString = data["data"];
  final postId = data["postId"];

  final stopwatch = Stopwatch()..start();

  final document = html.parse(htmlString);
  final htmlDocBenchmark = stopwatch.elapsed.inMilliseconds;
  stopwatch.reset();

  final original = document
      .getElementById("original-artist-commentary")
      // ?.querySelector("div[class='prose ']")
      ?.innerHtml;

  final translated = document
      .getElementById("translated-artist-commentary")
      // ?.querySelector("div[class='prose ']")
      ?.innerHtml;

  final artistCommentary =
      ArtistCommentary(original: original, translated: translated);
  final artistCommentaryBenchmark = stopwatch.elapsed.inMilliseconds;
  stopwatch.reset();

  final contentNode = document.getElementById('content');
  final isFavorited =
      contentNode.querySelector("div[class='fav-buttons fav-buttons-true']") !=
          null;

  final commentCount = contentNode
      .querySelector("section[id='comments']")
      .querySelector("div[class='list-of-comments list-of-messages']")
      .querySelectorAll("article[class='comment message']")
      .length;

  final favCount = document.getElementById('favcount-for-post-$postId').text;

  final postStatistics = PostStatistics(
      favCount: int.parse(favCount),
      commentCount: commentCount,
      isFavorited: isFavorited);

  final postStatisticsBenchmark = stopwatch.elapsed.inMilliseconds;
  stopwatch.reset();

  print(
      'parsed detail in $htmlDocBenchmark + $artistCommentaryBenchmark + $postStatisticsBenchmark = ${htmlDocBenchmark + artistCommentaryBenchmark + postStatisticsBenchmark}ms'
          .toUpperCase());
  return PostDetail(
      artistCommentary: artistCommentary, postStatistics: postStatistics);
}
