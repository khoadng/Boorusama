// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'blacklisted_tags_notifier.dart';

class BlacklistedTagsRepositoryImpl implements BlacklistedTagsRepository {
  BlacklistedTagsRepositoryImpl(
    this.userRepository,
    this.api,
  );

  final UserRepository userRepository;
  final DanbooruApi api;
  final Map<int, List<String>> _blacklistedTagsCache = {};

  @override
  Future<List<String>> getBlacklistedTags(int uid) async {
    if (_blacklistedTagsCache.containsKey(uid)) {
      return _blacklistedTagsCache[uid]!;
    }

    final tags = await userRepository
        .getUserSelfById(uid)
        .then((value) => value?.blacklistedTags ?? <String>[]);

    _blacklistedTagsCache[uid] = tags;
    return tags;
  }

  @override
  Future<bool> setBlacklistedTags(
    int userId,
    List<String> tags,
  ) async {
    try {
      await api.setBlacklistedTags(
        userId,
        tagsToTagString(tags),
      );

      // Clear the cache for the user
      _blacklistedTagsCache.remove(userId);

      return true;
    } catch (e) {
      return false;
    }
  }
}
