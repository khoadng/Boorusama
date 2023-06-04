// Project imports:
import 'package:boorusama/core/tags/tags.dart';

class EmptyBlacklistedTagsRepository implements BlacklistedTagsRepository {
  @override
  Future<List<String>> getBlacklistedTags(int uid) async => [];

  @override
  Future<bool> setBlacklistedTags(int uid, List<String> tags) async => true;
}
