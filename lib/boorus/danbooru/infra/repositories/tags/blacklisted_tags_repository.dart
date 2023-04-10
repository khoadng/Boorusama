// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

class BlacklistedTagsRepositoryImpl implements BlacklistedTagsRepository {
  BlacklistedTagsRepositoryImpl(
    this.userRepository,
    this.currentBooruConfigRepository,
    this.api,
  );

  final UserRepository userRepository;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final DanbooruApi api;

  @override
  Future<List<String>> getBlacklistedTags(int uid) {
    return userRepository
        .getUserSelfById(uid)
        .then((value) => value?.blacklistedTags ?? []);
  }

  @override
  Future<bool> setBlacklistedTags(
    int userId,
    List<String> tags,
  ) async {
    try {
      await currentBooruConfigRepository
          .get()
          .then((booruConfig) => api.setBlacklistedTags(
                booruConfig?.login,
                booruConfig?.apiKey,
                userId,
                tagsToTagString(tags),
              ));

      return true;
    } catch (e) {
      return false;
    }
  }
}
