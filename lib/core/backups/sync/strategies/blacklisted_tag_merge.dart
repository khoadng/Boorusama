// Project imports:
import '../../../blacklists/types.dart';
import '../merge_strategy.dart';

class BlacklistedTagMergeStrategy extends MergeStrategy<BlacklistedTag> {
  @override
  Object getUniqueId(BlacklistedTag item) => item.name;

  @override
  Object getUniqueIdFromJson(Map<String, dynamic> json) =>
      json['name'] as String? ?? '';

  @override
  DateTime? getTimestamp(BlacklistedTag item) => item.updatedDate;
}
