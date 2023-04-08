// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/main.dart';

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
    this.dioProvider,
    this.booruFactory,
  );

  final DioProvider dioProvider;
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
      print('in cached: $cacheKey');
      return _accountIdCache[cacheKey];
    }

    print('fetch new: $cacheKey');

    int? accountId;

    switch (booru.booruType) {
      case BooruType.gelbooru:
        accountId = int.tryParse(login);
        break;
      case BooruType.unknown:
        throw UnimplementedError();
      case BooruType.danbooru:
      case BooruType.safebooru:
      case BooruType.testbooru:
      case BooruType.aibooru:
        accountId = await DanbooruApi(dioProvider.getDio(booru.url))
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
