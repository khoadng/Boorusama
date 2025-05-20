// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../posts/post/post.dart';
import '../../categories/providers.dart';
import '../providers.dart';
import 'tag_group_item.dart';

final invalidTags = [
  ':&lt;',
];

final tagGroupProvider = AsyncNotifierProvider.autoDispose
    .family<TagGroupItemNotifier, TagGroup, Post>(
  TagGroupItemNotifier.new,
);

class TagGroup extends Equatable {
  const TagGroup({
    required this.characterTags,
    required this.artistTags,
    required this.tags,
  });

  const TagGroup.empty()
      : characterTags = const {},
        artistTags = const {},
        tags = const [];

  final Set<String> characterTags;
  final Set<String> artistTags;
  final List<TagGroupItem> tags;

  @override
  List<Object?> get props => [characterTags, artistTags, tags];
}

class TagGroupItemNotifier
    extends AutoDisposeFamilyAsyncNotifier<TagGroup, Post> {
  @override
  FutureOr<TagGroup> build(Post arg) async {
    final config = ref.watchConfigAuth;
    final booruTagTypeStore = ref.watch(booruTagTypeStoreProvider);
    final repo = ref.watch(tagRepoProvider(config));
    final tagList = arg.tags;

    // filter tagList to remove invalid tags
    final filtered = tagList.where((e) => !invalidTags.contains(e)).toSet();

    if (filtered.isEmpty) return const TagGroup.empty();

    final tags = await repo.getTagsByName(filtered, 1);

    await booruTagTypeStore.saveTagIfNotExist(config.booruType, tags);

    final group = createTagGroupItems(tags);

    return TagGroup(
      characterTags: group
              .firstWhereOrNull(
                (tag) => tag.groupName.toLowerCase() == 'character',
              )
              ?.extractCharacterTags()
              .toSet() ??
          {},
      artistTags: group
              .firstWhereOrNull(
                (tag) => tag.groupName.toLowerCase() == 'artist',
              )
              ?.extractArtistTags()
              .toSet() ??
          {},
      tags: group,
    );
  }
}
