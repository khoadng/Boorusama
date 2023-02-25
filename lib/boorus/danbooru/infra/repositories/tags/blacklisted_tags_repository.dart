// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

class BlacklistedTagsRepositoryImpl implements BlacklistedTagsRepository {
  BlacklistedTagsRepositoryImpl(
    this.userRepository,
  );

  final UserRepository userRepository;

  @override
  Future<List<String>> getBlacklistedTags(int uid) {
    return userRepository
        .getUserById(uid)
        .then((value) => value.blacklistedTags);
  }

  @override
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
