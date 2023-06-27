// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/dart.dart';

final invalidTags = [
  ':&lt;',
];

class TagsNotifier extends Notifier<List<TagGroupItem>?> {
  @override
  List<TagGroupItem>? build() {
    ref.watch(currentBooruConfigProvider);
    return null;
  }

  TagRepository get repo => ref.read(tagRepoProvider);

  Future<void> load(
    List<String> tagList, {
    void Function(List<TagGroupItem> tags)? onSuccess,
  }) async {
    // filter tagList to remove invalid tags
    final filtered = tagList.where((e) => !invalidTags.contains(e)).toList();
    final tags = await repo.getTagsByNameComma(filtered.join(','), 1);

    tags.sort((a, b) => a.rawName.compareTo(b.rawName));
    final group = tags
        .groupBy((e) => e.category)
        .entries
        .map((e) => TagGroupItem(
              category: e.key.index,
              groupName: tagCategoryToString(e.key),
              tags: e.value,
              order: tagCategoryToOrder(e.key),
            ))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    onSuccess?.call(group);

    state = group;
  }
}

String tagCategoryToString(TagCategory category) => switch (category) {
      TagCategory.artist => 'Artist',
      TagCategory.charater => 'Character',
      TagCategory.copyright => 'Copyright',
      TagCategory.general => 'General',
      TagCategory.meta => 'Meta',
      TagCategory.invalid_ => ''
    };

typedef TagCategoryOrder = int;

TagCategoryOrder tagCategoryToOrder(TagCategory category) => switch (category) {
      TagCategory.artist => 0,
      TagCategory.copyright => 1,
      TagCategory.charater => 2,
      TagCategory.general => 3,
      TagCategory.meta => 4,
      TagCategory.invalid_ => 5
    };
