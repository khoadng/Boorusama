// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

class BlacklistedTagsRepositoryImpl implements BlacklistedTagsRepository {
  BlacklistedTagsRepositoryImpl(
    this.userRepository,
    this.client,
  );

  final UserRepository userRepository;
  final DanbooruClient client;
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
      await client.setBlacklistedTags(
        id: userId,
        blacklistedTags: tags,
      );

      // Clear the cache for the user
      _blacklistedTagsCache.remove(userId);

      return true;
    } catch (e) {
      return false;
    }
  }
}
