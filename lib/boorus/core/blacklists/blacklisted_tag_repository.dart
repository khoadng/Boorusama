// Project imports:

// Project imports:
import 'package:boorusama/boorus/core/blacklists/blacklists.dart';

abstract class GlobalBlacklistedTagRepository {
  Future<BlacklistedTag> addTag(String tag);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
}

Future<Set<String>> getBlacklistedTags(
        GlobalBlacklistedTagRepository blacklistedTagRepository) =>
    blacklistedTagRepository
        .getBlacklist()
        .then((tags) => tags.map((tag) => tag.name).toSet());
