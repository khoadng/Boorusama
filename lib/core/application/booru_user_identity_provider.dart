// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/booru.dart';

abstract class BooruUserIdentityProvider {
  Future<int> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  });
}

class BooruUserIdentityProviderImpl implements BooruUserIdentityProvider {
  BooruUserIdentityProviderImpl(
    this.api,
  );

  final Api api;

  @override
  Future<int> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  }) async {
    switch (booru.booruType) {
      case BooruType.gelbooru:
      case BooruType.unknown:
        throw UnimplementedError();
      case BooruType.danbooru:
      case BooruType.safebooru:
      case BooruType.testbooru:
        final id = await api
            .getProfile(
              login,
              apiKey,
            )
            .then((value) => value.data)
            .then((value) => value['id'])
            .catchError((_) => null);

        if (id == null) throw Exception('Profile is null');

        return id;
    }
  }
}
