// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/tags/categories/providers.dart';
import '../../../../../core/tags/tag/providers.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../tags/_shared/tag_list_notifier.dart';
import '../../post/post.dart';

final danbooruTagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, DanbooruPost>((ref, post) async {
  final config = ref.watchConfigAuth;
  final tagsNotifier = ref.watch(danbooruTagListProvider(config));

  final tagString = tagsNotifier.containsKey(post.id)
      ? tagsNotifier[post.id]!.allTags
      : post.tags;

  final repo = ref.watch(tagRepoProvider(config));

  final tags = await repo.getTagsByName(tagString, 1);

  final tagTypeStore = await ref.watch(booruTagTypeStoreProvider.future);

  await tagTypeStore.saveTagIfNotExist(config.url, tags);

  return createTagGroupItems(tags);
});
