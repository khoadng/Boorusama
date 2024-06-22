// convert a BooruConfig and an orignal tag list to List<String>

// Project imports:
import 'package:boorusama/core/configs/configs.dart';

List<String> getTags(
  BooruConfig booruConfig,
  List<String> tags, {
  List<String>? Function(List<String> tags)? granularRatingQueries,
}) {
  final deletedStatusTag = booruConfigDeletedBehaviorToTag(
    booruConfig.deletedItemBehavior,
  );

  final data = [
    ...tags,
    if (deletedStatusTag != null) deletedStatusTag,
  ];

  return granularRatingQueries != null
      ? granularRatingQueries(data) ?? []
      : data;
}

String? booruConfigDeletedBehaviorToTag(
  BooruConfigDeletedItemBehavior? behavior,
) {
  if (behavior == null) return null;

  return switch (behavior) {
    BooruConfigDeletedItemBehavior.show => null,
    BooruConfigDeletedItemBehavior.hide => '-status:deleted'
  };
}
