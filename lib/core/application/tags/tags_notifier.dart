// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/utils/collection_utils.dart';
import 'tags_providers.dart';

final invalidTags = [
  ':&lt;',
];

class TagsNotifier extends Notifier<List<TagGroupItem>> {
  @override
  List<TagGroupItem> build() {
    ref.watch(currentBooruConfigProvider);
    return [];
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

class TagGroupItem extends Equatable {
  const TagGroupItem({
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;

  @override
  List<Object?> get props => [groupName, tags, order];
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
