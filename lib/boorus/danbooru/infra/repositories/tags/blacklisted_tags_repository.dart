// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

class BlacklistedTagsRepositoryImpl implements BlacklistedTagsRepository {
  BlacklistedTagsRepositoryImpl(
    this.userRepository,
    this.currentUserBooruRepository,
    this.api,
  );

  final UserRepository userRepository;
  final CurrentUserBooruRepository currentUserBooruRepository;
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
      await currentUserBooruRepository
          .get()
          .then((booruUser) => api.setBlacklistedTags(
                booruUser?.login,
                booruUser?.apiKey,
                userId,
                tagsToTagString(tags),
              ));

      return true;
    } catch (e) {
      return false;
    }
  }
}
