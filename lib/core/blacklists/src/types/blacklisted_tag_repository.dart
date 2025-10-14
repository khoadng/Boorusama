// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import 'blacklisted_tag.dart';

abstract class GlobalBlacklistedTagRepository {
  Future<BlacklistedTag?> addTag(String tag);
  Future<List<BlacklistedTag>> addTags(List<BlacklistedTag> tags);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
  Future<BlacklistedTag> updateTag(int tagId, String newTag);
}

abstract class BlacklistTagRefRepository {
  Ref get ref;

  Future<Set<String>> getBlacklistedTags(BooruConfigAuth config);
}
