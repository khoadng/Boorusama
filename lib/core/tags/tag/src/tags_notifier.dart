// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../categories/providers.dart';
import '../providers.dart';
import 'tag_group_item.dart';

final invalidTags = [
  ':&lt;',
];

final tagGroupProvider = AsyncNotifierProvider.autoDispose
    .family<TagGroupItemNotifier, TagGroup, TagGroupParams>(
  TagGroupItemNotifier.new,
);

typedef TagGroupParams = ({
  Post post,
  BooruConfigAuth auth,
});

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
    extends AutoDisposeFamilyAsyncNotifier<TagGroup, TagGroupParams> {
  @override
  FutureOr<TagGroup> build(TagGroupParams arg) async {
    final post = arg.post;
    final config = arg.auth;

    final booruTagTypeStore = await ref.watch(booruTagTypeStoreProvider.future);
    final repo = ref.watch(tagRepoProvider(config));
    final tagList = post.tags;

    // filter tagList to remove invalid tags
    final filtered = tagList.where((e) => !invalidTags.contains(e)).toSet();

    if (filtered.isEmpty) return const TagGroup.empty();

    final tags = await repo.getTagsByName(filtered, 1);

    await booruTagTypeStore.saveTagIfNotExist(config.url, tags);

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
