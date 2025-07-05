// Project imports:
import '../../../categories/tag_category.dart';
import 'tag.dart';

class TagSorter {
  const TagSorter({
    required this.categoryOrder,
  });

  factory TagSorter.defaults() => TagSorter(
        categoryOrder: {
          TagCategory.artist().name: 0,
          TagCategory.copyright().name: 1,
          TagCategory.character().name: 2,
          TagCategory.general().name: 3,
          TagCategory.meta().name: 4,
        },
      );

  final Map<String, int> categoryOrder;

  List<Tag> sortTagsByCategory(List<Tag> tags) {
    final groupedTags = <TagCategory, List<Tag>>{};
    for (final tag in tags) {
      groupedTags.putIfAbsent(tag.category, () => []).add(tag);
    }

    groupedTags.forEach((category, tagList) {
      tagList.sort((a, b) => a.name.compareTo(b.name));
    });

    final sortedCategories = groupedTags.keys.toList()
      ..sort((a, b) {
        final aOrder = categoryOrder[a.name];
        final bOrder = categoryOrder[b.name];

        if (aOrder != null && bOrder != null) {
          return aOrder.compareTo(bOrder);
        }
        if (aOrder != null) return -1;
        if (bOrder != null) return 1;

        // Fall back to category order or name
        final aOrderValue = a.order;
        final bOrderValue = b.order;
        if (aOrderValue != bOrderValue) {
          return (aOrderValue ?? 999).compareTo(bOrderValue ?? 999);
        }
        return a.name.compareTo(b.name);
      });

    return sortedCategories
        .expand((category) => groupedTags[category]!)
        .toList();
  }
}
