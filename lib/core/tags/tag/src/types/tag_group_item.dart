// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/utils/collection_utils.dart';
import '../../../categories/types.dart';
import 'tag.dart';
import 'tag_display.dart';

class TagGroupItem extends Equatable {
  const TagGroupItem({
    required this.category,
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final int category;
  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;

  @override
  List<Object?> get props => [category, groupName, tags, order];
}

List<TagGroupItem> createTagGroupItems(List<Tag> tags) {
  tags.sort((a, b) => a.rawName.compareTo(b.rawName));
  final group =
      tags
          .groupBy((e) => e.category)
          .entries
          .map(
            (e) => TagGroupItem(
              category: e.key.id,
              groupName: e.key.displayName ?? e.key.name.sentenceCase,
              tags: e.value,
              order: e.key.order ?? 99999,
            ),
          )
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  return group;
}
