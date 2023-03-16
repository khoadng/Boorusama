import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profiles.dart';

abstract class BooruUserIdentityProvider {
  Future<int> getAccountId({
    required Booru booru,
    required String login,
    required String apiKey,
  });
}

class BooruUserIdentityProviderImpl implements BooruUserIdentityProvider {
  BooruUserIdentityProviderImpl(
    this.profileRepository,
  );

  final ProfileRepository profileRepository;

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
        final profile = await profileRepository.getProfile(
          username: login,
          apiKey: apiKey,
        );

        if (profile == null) throw Exception('Profile is null');

        return profile.id;
    }
  }
}
