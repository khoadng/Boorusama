// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:html/parser.dart' as html;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_statistics_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_statistics.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/cache/post_statistics_cache.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/cache/post_statistics_cache_decorator.dart';

final postStatisticsProvider = Provider<IPostStatisticsRepository>((ref) {
  final cache = ref.watch(postStatisticsCacheProvider);
  final endpoint = ref.watch(apiEndpointProvider);
  final repo = PostStatisticsRepository(
      ref.watch(apiProvider), ref.watch(accountProvider));

  //TODO: caching is broken, re-add later
  return repo;
});

class PostStatisticsRepository implements IPostStatisticsRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  PostStatisticsRepository(this._api, this._accountRepository);

  @override
  Future<PostStatistics> getPostStatistics(int id) async {
    final account = await _accountRepository.get();

    return _api.getPost(account.username, account.apiKey, id).then((value) {
      final data = value.response.data.toString();
      final Map<String, dynamic> payload = {"data": data, "postId": id};
      final statistics = compute(parseStatistics, payload);

      return statistics;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          throw Exception("Failed to get post for $id");
          break;
        default:
      }
      return null;
    });
  }
}

PostStatistics parseStatistics(Map<String, dynamic> data) {
  final htmlString = data["data"];
  final postId = data["postId"];

  final stopwatch = Stopwatch()..start();

  final document = html.parse(htmlString);

  final contentNode =
      document.documentElement.querySelector("section[id='content']");
  final isFavorited =
      contentNode.querySelector("div[class='fav-buttons fav-buttons-true']") !=
          null;

  final commentCount = contentNode
      .querySelector("section[id='comments']")
      .querySelector("div[class='list-of-comments list-of-messages']")
      .querySelectorAll("article[class='comment message']")
      .length;

  final favCount = document.documentElement
      .querySelector("span[id='favcount-for-post-$postId']")
      .text;

  print('parsed statistics in ${stopwatch.elapsed.inMilliseconds}ms'
      .toUpperCase());
  return PostStatistics(
      favCount: int.parse(favCount),
      commentCount: commentCount,
      isFavorited: isFavorited);
}
