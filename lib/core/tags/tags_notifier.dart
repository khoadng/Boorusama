// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/string.dart';

final invalidTags = [
  ':&lt;',
];

class TagsNotifier extends FamilyNotifier<List<TagGroupItem>?, BooruConfig> {
  @override
  List<TagGroupItem>? build(BooruConfig arg) {
    return null;
  }

  TagRepository get repo => ref.read(tagRepoProvider(arg));

  Future<void> load(
    Set<String> tagList, {
    void Function(List<TagGroupItem> tags)? onSuccess,
  }) async {
    state = null;
    final booruTagTypeStore = ref.read(booruTagTypeStoreProvider);

    final tags = await loadTags(tagList: tagList, repo: repo);

    await booruTagTypeStore.saveTagIfNotExist(arg.booruType, tags);

    final group = createTagGroupItems(tags);

    onSuccess?.call(group);

    state = group;
  }
}

Future<List<Tag>> loadTags({
  required Set<String> tagList,
  required TagRepository repo,
}) async {
  // filter tagList to remove invalid tags
  final filtered = tagList.where((e) => !invalidTags.contains(e)).toSet();

  if (filtered.isEmpty) return [];

  final tags = await repo.getTagsByName(filtered, 1);

  return tags;
}

List<TagGroupItem> createTagGroupItems(List<Tag> tags) {
  tags.sort((a, b) => a.rawName.compareTo(b.rawName));
  final group = tags
      .groupBy((e) => e.category)
      .entries
      .map((e) => TagGroupItem(
            category: e.key.id,
            groupName: e.key.name.sentenceCase,
            tags: e.value,
            order: e.key.order ?? 99999,
          ))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  return group;
}
