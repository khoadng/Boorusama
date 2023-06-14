abstract class BlacklistedTagsRepository {
  Future<List<String>> getBlacklistedTags(int uid);
  Future<bool> setBlacklistedTags(int uid, List<String> tags);
}
