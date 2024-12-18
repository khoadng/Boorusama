// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../configs/current.dart';
import '../../categories/providers.dart';
import '../providers.dart';
import 'tag.dart';
import 'tag_group_item.dart';
import 'tag_repository.dart';

final invalidTags = [
  ':&lt;',
];

final tagsProvider =
    NotifierProvider.family<TagsNotifier, List<TagGroupItem>?, BooruConfigAuth>(
  TagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

class TagsNotifier
    extends FamilyNotifier<List<TagGroupItem>?, BooruConfigAuth> {
  @override
  List<TagGroupItem>? build(BooruConfigAuth arg) {
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
