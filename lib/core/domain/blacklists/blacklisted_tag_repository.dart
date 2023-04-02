// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag.dart';

abstract class BlacklistedTagRepository {
  Future<BlacklistedTag> addTag(String tag);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
}
