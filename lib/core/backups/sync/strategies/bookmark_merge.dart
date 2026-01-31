// Project imports:
import '../../../bookmarks/types.dart';
import '../merge_strategy.dart';

class BookmarkMergeStrategy extends MergeStrategy<Bookmark> {
  @override
  Object getUniqueId(Bookmark item) => item.uniqueId;

  @override
  Object getUniqueIdFromJson(Map<String, dynamic> json) {
    final booruId = json['booruId'] as int? ?? 0;
    final originalUrl = json['originalUrl'] as String? ?? '';
    return BookmarkUniqueId(booruId: booruId, url: originalUrl);
  }

  @override
  DateTime? getTimestamp(Bookmark item) => item.updatedAt;
}
