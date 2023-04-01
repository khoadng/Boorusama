// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/main.dart';

abstract class BooruUserIdentityProvider {
  Future<int> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  });
}

class BooruUserIdentityProviderImpl implements BooruUserIdentityProvider {
  BooruUserIdentityProviderImpl(this.dioProvider);

  final DioProvider dioProvider;

  @override
  Future<int> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  }) async {
    switch (booru.booruType) {
      case BooruType.gelbooru:
        return int.parse(login);
      case BooruType.unknown:
        throw UnimplementedError();
      case BooruType.danbooru:
      case BooruType.safebooru:
      case BooruType.testbooru:
      case BooruType.aibooru:
        final id = await DanbooruApi(dioProvider.getDio(booru.url))
            .getProfile(
          login,
          apiKey,
        )
            .then((value) {
          return value.data;
        }).then((value) {
          return value['id'];
        }).catchError((_) => null);

        if (id == null) throw Exception('Profile is null');

        return id;
      case BooruType.konachan:
        return 0;
    }
  }
}
