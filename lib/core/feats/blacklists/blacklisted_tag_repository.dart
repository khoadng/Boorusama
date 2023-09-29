// Project imports:

// Project imports:
import 'package:boorusama/core/feats/blacklists/blacklists.dart';

abstract class GlobalBlacklistedTagRepository {
  Future<BlacklistedTag?> addTag(String tag);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
  Future<BlacklistedTag> updateTag(int tagId, String newTag);
}
