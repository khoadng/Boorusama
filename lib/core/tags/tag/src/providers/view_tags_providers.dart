// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../categories/tag_category.dart';
import '../../../local/cached_tag.dart';
import '../../../local/providers.dart';
import '../../tag.dart';

typedef ViewTagsWithCachedParams = ({
  BooruConfigAuth auth,
  String tagString,
});

final defaultTagsFromCacheProvider = FutureProvider.autoDispose
    .family<List<Tag>, ViewTagsWithCachedParams>((ref, params) async {
  final siteHost = params.auth.url;
  final tagString = params.tagString;
  final tagCache = await ref.watch(tagCacheRepositoryProvider.future);

  final tagNames = tagString
      .split(' ')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  final result = await tagCache.resolveTags(siteHost, tagNames);

  final tags = _mapCachedTagsToTags(result.allTags);

  // group by category
  final groupedTags = <TagCategory, List<Tag>>{};
  for (final tag in tags) {
    final category = tag.category;
    if (!groupedTags.containsKey(category)) {
      groupedTags[category] = [];
    }
    groupedTags[category]!.add(tag);
  }

  // sort by name
  for (final category in groupedTags.keys) {
    groupedTags[category]!.sort((a, b) => a.name.compareTo(b.name));
  }

  final customOrderOverride = {
    TagCategory.artist().name: 0,
    TagCategory.copyright().name: 1,
    TagCategory.character().name: 2,
    TagCategory.general().name: 3,
    TagCategory.meta().name: 4,
  };

  final sortedCategories = groupedTags.keys.toList()
    ..sort((a, b) {
      final aCustomOrder = customOrderOverride[a.name];
      final bCustomOrder = customOrderOverride[b.name];

      // Use custom order if both have it
      if (aCustomOrder != null && bCustomOrder != null) {
        return aCustomOrder.compareTo(bCustomOrder);
      }
      // If only one has custom order, prioritize it
      if (aCustomOrder != null) return -1;
      if (bCustomOrder != null) return 1;

      // Fall back to existing order system
      final aOrder = a.order;
      final bOrder = b.order;
      if (aOrder != bOrder) {
        return aOrder?.compareTo(bOrder ?? 999) ?? 999;
      }
      return a.name.compareTo(b.name);
    });

  // flatten the map to a list
  final sortedTags =
      sortedCategories.expand((category) => groupedTags[category]!).toList();

  return sortedTags;
});

List<Tag> _mapCachedTagsToTags(List<CachedTag> cachedTags) => cachedTags
    .map(
      (cachedTag) => Tag(
        name: cachedTag.tagName,
        category: TagCategory.fromLegacyIdString(cachedTag.category),
        postCount: cachedTag.postCount ?? 0,
      ),
    )
    .toList();
