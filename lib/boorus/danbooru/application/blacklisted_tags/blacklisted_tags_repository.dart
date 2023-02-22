// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class BlacklistedTagsRepository {
  BlacklistedTagsRepository(
    this.userRepository,
  );

  final UserRepository userRepository;

  Future<List<String>> getBlacklistedTags(int uid) {
    return userRepository
        .getUserById(uid)
        .then((value) => value.blacklistedTags);
  }

  Future<bool> setBlacklistedTags(
    int userId,
    List<String> tags,
  ) async {
    try {
      await userRepository.setUserBlacklistedTags(
        userId,
        tagsToTagString(tags),
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
