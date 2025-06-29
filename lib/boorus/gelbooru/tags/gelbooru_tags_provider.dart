// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../gelbooru.dart';

final invalidTags = [
  ':&lt;',
];

final gelbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTags(
          page: page,
          tags: tags,
        );

        return data
            .map(
              (e) => Tag(
                name: e.name != null ? decodeHtmlEntities(e.name!) : '',
                category: TagCategory.fromLegacyId(e.type),
                postCount: e.count ?? 0,
              ),
            )
            .toList();
      },
    );
  },
);

final gelbooruTagGroupRepoProvider =
    Provider.family<TagGroupRepository<GelbooruPost>, BooruConfigAuth>(
  (ref, config) {
    final tagRepo = ref.watch(gelbooruTagRepoProvider(config));

    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post) async {
        final tagList = post.tags;

        // filter tagList to remove invalid tags
        final filtered = tagList.where((e) => !invalidTags.contains(e)).toSet();

        if (filtered.isEmpty) return const [];

        final tags = await tagRepo.getTagsByName(filtered, 1);

        return createTagGroupItems(tags);
      },
    );
  },
);

final tagGroupProvider = AsyncNotifierProvider.autoDispose
    .family<TagGroupItemNotifier, TagGroup, TagGroupParams>(
  TagGroupItemNotifier.new,
);

typedef TagGroupParams = ({
  GelbooruPost post,
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

    final repo = ref.watch(gelbooruTagGroupRepoProvider(config));
    final group = await repo.getTagGroups(post);

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
