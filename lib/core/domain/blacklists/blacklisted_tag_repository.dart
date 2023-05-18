// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag.dart';

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
