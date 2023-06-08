// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';

abstract class BooruUserIdentityProvider {
  Future<int?> getAccountIdFromConfig(BooruConfig? config);

  Future<int?> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  });
}

class BooruUserIdentityProviderImpl implements BooruUserIdentityProvider {
  BooruUserIdentityProviderImpl(
    this.dio,
    this.booruFactory,
  );

  final Dio dio;
  final BooruFactory booruFactory;
  final Map<String, int?> _accountIdCache =
      {}; // <Booru.url + login, accountId>

  @override
  Future<int?> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  }) async {
    final cacheKey = '${booru.url}+$login';

    if (_accountIdCache.containsKey(cacheKey)) {
      return _accountIdCache[cacheKey];
    }

    int? accountId;

    switch (booru.booruType) {
      case BooruType.gelbooru:
      case BooruType.rule34xxx:
        accountId = int.tryParse(login);
        break;
      case BooruType.unknown:
        throw UnimplementedError();
      case BooruType.danbooru:
      case BooruType.safebooru:
      case BooruType.testbooru:
      case BooruType.aibooru:
        accountId = await DanbooruApi(dio, baseUrl: booru.url)
            .getProfile(
              login,
              apiKey,
            )
            .then((value) => value.data)
            .then((value) => value['id'])
            .catchError((_) => null);
        break;
      case BooruType.konachan:
      case BooruType.yandere:
      case BooruType.sakugabooru:
        accountId = 0;
        break;
    }

    _accountIdCache[cacheKey] = accountId;
    return accountId;
  }

  @override
  Future<int?> getAccountIdFromConfig(BooruConfig? config) =>
      (!config.hasLoginDetails() || config == null)
          ? Future.value(null)
          : getAccountId(
              booru: config.createBooruFrom(booruFactory),
              login: config.login!,
              apiKey: config.apiKey!,
            );
}
