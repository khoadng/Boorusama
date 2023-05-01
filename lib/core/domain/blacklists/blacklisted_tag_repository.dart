// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag.dart';

abstract class BlacklistedTagRepository {
  Future<BlacklistedTag> addTag(String tag);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
}

Future<Set<String>> getBlacklistedTags(
        BlacklistedTagRepository blacklistedTagRepository) =>
    blacklistedTagRepository
        .getBlacklist()
        .then((tags) => tags.map((tag) => tag.name).toSet());
