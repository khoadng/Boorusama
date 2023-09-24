// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

final danbooruPostDetailsArtistProvider = FutureProvider.family
    .autoDispose<List<Recommend<DanbooruPost>>, DanbooruPost>(
        (ref, post) async {
  final repo = ref.watch(danbooruArtistCharacterPostRepoProvider);
  final blacklistedTags = ref.watch(danbooruBlacklistedTagsProvider);
  final globalBlacklistedTags = ref.watch(globalBlacklistedTagsProvider);

  final tags = post.artistTags;
  List<Recommend<DanbooruPost>> state = [];

  for (final tag in tags) {
    List<DanbooruPost> posts;

    posts = await repo
        .getPosts(tag, 1)
        .run()
        .then((value) => value.fold((l) => [], (r) => r));

    posts = posts.take(30).toList();

    state.add(Recommend(
      type: RecommendType.artist,
      title: tag.replaceAll('_', ' '),
      tag: tag,
      posts: filterTags(
        posts.where((e) => !e.isFlash).toList(),
        {
          if (blacklistedTags != null) ...blacklistedTags,
          ...globalBlacklistedTags.map((e) => e.name),
        },
      ),
    ));
  }

  return state;
});

final danbooruPostDetailsCharacterProvider = FutureProvider.family
    .autoDispose<List<Recommend<DanbooruPost>>, DanbooruPost>(
        (ref, post) async {
  final repo = ref.watch(danbooruArtistCharacterPostRepoProvider);
  final blacklistedTags = ref.watch(danbooruBlacklistedTagsProvider);
  final globalBlacklistedTags = ref.watch(globalBlacklistedTagsProvider);

  final tags = post.characterTags.take(3);
  List<Recommend<DanbooruPost>> state = [];

  for (final tag in tags) {
    List<DanbooruPost> posts;

    posts = await repo
        .getPosts(tag, 1)
        .run()
        .then((value) => value.fold((l) => [], (r) => r));

    posts = posts.take(30).toList();

    state.add(Recommend(
      type: RecommendType.character,
      title: tag.replaceAll('_', ' '),
      tag: tag,
      posts: filterTags(
        posts.where((e) => !e.isFlash).toList(),
        {
          if (blacklistedTags != null) ...blacklistedTags,
          ...globalBlacklistedTags.map((e) => e.name),
        },
      ),
    ));
  }

  return state;
});

final danbooruPostDetailsChildrenProvider = FutureProvider.family
    .autoDispose<List<DanbooruPost>, DanbooruPost>((ref, post) async {
  if (!post.hasParentOrChildren) return [];

  final repo = ref.watch(danbooruPostRepoProvider);

  final posts = await repo
      .getPosts(
        post.hasParent ? 'parent:${post.parentId}' : 'parent:${post.id}',
        1,
      )
      .run()
      .then((value) => value.fold((l) => <DanbooruPost>[], (r) => r));

  return posts;
});

final danbooruPostDetailsPoolsProvider =
    FutureProvider.family.autoDispose<List<Pool>, int>((ref, postId) async {
  final repo = ref.watch(danbooruPoolRepoProvider);

  return repo.getPoolsByPostId(postId);
});
