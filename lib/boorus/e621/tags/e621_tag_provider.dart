// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../e621.dart';
import '../posts/posts.dart';
import 'e621_tag_category.dart';
import 'e621_tag_repository.dart';

final e621TagRepoProvider =
    Provider.family<E621TagRepository, BooruConfigAuth>((ref, config) {
  return E621TagRepositoryApi(
    ref.watch(e621ClientProvider(config)),
    config,
  );
});

final e621TagGroupRepoProvider =
    Provider.family<TagGroupRepository<E621Post>, BooruConfigAuth>(
  (ref, config) {
    return TagGroupRepositoryBuilder(
      ref: ref,
      loadGroups: (post) async {
        return createTagGroupItems([
          ...post.artistTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621ArtistTagCategory,
            ),
          ),
          ...post.characterTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621CharacterTagCategory,
            ),
          ),
          ...post.speciesTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621SpeciesTagCategory,
            ),
          ),
          ...post.copyrightTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621CopyrightTagCategory,
            ),
          ),
          ...post.generalTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621GeneralTagCategory,
            ),
          ),
          ...post.metaTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621MetaTagCagegory,
            ),
          ),
          ...post.loreTags.map(
            (e) => Tag.noCount(
              name: e,
              category: e621LoreTagCategory,
            ),
          ),
        ]);
      },
    );
  },
);

final e621TagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, (BooruConfigAuth, E621Post)>(
        (ref, params) async {
  final config = params.$1;
  final post = params.$2;

  final tagGroupRepo = ref.watch(e621TagGroupRepoProvider(config));

  return tagGroupRepo.getTagGroups(post);
});
