// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/utils/collection_utils.dart';

final danbooruPostDetailsProvider =
    NotifierProvider<DanbooruPostDetailsNotifier, PostDetailState>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsProvider,
    danbooruPostRepoProvider,
    poolRepoProvider,
    noteRepoProvider,
  ],
);

class DanbooruPostDetailsNotifier extends Notifier<PostDetailState>
    with DanbooruPostRepositoryMixin {
  DanbooruPostDetailsNotifier({
    required this.posts,
    required this.initialIndex,
  }) : super();

  final List<DanbooruPost> posts;
  final int initialIndex;
  final Map<String, List<DanbooruPost>> tagCache = {};
  final Set<int> _loaded = {};

  @override
  DanbooruPostRepository get postRepository =>
      ref.read(danbooruPostRepoProvider);

  @override
  PostDetailState build() {
    final settings = ref.watch(settingsProvider);
    final tags = posts
        .map((e) => e)
        .map((p) => [
              ...p.artistTags.map((e) => PostDetailTag(
                    name: e,
                    category: TagCategory.artist.stringify(),
                    postId: p.id,
                  )),
              ...p.characterTags.map((e) => PostDetailTag(
                    name: e,
                    category: TagCategory.charater.stringify(),
                    postId: p.id,
                  )),
              ...p.copyrightTags.map((e) => PostDetailTag(
                    name: e,
                    category: TagCategory.copyright.stringify(),
                    postId: p.id,
                  )),
              ...p.generalTags.map((e) => PostDetailTag(
                    name: e,
                    category: TagCategory.general.stringify(),
                    postId: p.id,
                  )),
              ...p.metaTags.map((e) => PostDetailTag(
                    name: e,
                    category: TagCategory.meta.stringify(),
                    postId: p.id,
                  )),
            ])
        .expand((e) => e)
        .toList();

    return PostDetailState(
      tags: tags,
      currentIndex: initialIndex,
      currentPost: posts[initialIndex],
      slideShowConfig: PostDetailState.initial().slideShowConfig,
      recommends: const [],
      pools: const [],
      notes: const [],
      children: const [],
      fullScreen: settings.detailsDisplay != DetailsDisplay.postFocus,
    );
  }

  void loadData(int index) {
    if (_loaded.contains(index)) return;

    final post = posts[index];
    final nextPost = posts.getOrNull(index + 1);
    final prevPost = posts.getOrNull(index - 1);

    state = state.copyWith(
      currentIndex: index,
      currentPost: post,
      nextPost: () => nextPost,
      previousPost: () => prevPost,
      recommends: [],
      pools: [],
      notes: [],
      children: [],
    );

    if (post.isTranslated) {
      _loadNotes(post.id);
    }

    if (post.hasParentOrChildren) {
      if (post.hasParent) {
        _loadParentChildPosts(
          'parent:${post.parentId}',
        );
      } else {
        _loadParentChildPosts(
          'parent:${post.id}',
        );
      }
    }

    _loadPools(post.id);

    _loadRecommends(
      post.artistTags,
      post.characterTags,
    );

    _loaded.add(index);
  }

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }

  Future<void> _loadNotes(int postId) async {
    final notes = await ref.read(noteRepoProvider).getNotesFrom(postId);

    state = state.copyWith(notes: notes);
  }

  Future<void> _loadParentChildPosts(String tag) async {
    final posts = await getPostsOrEmpty(tag, 1);

    state = state.copyWith(children: posts);
  }

  Future<void> _loadPools(int postId) async {
    final pools = await ref.read(poolRepoProvider).getPoolsByPostId(postId);

    state = state.copyWith(pools: pools);
  }

  Future<void> _loadRecommends(
    List<String> artistTags,
    List<String> characterTags,
  ) async {
    await _fetchArtistPosts(artistTags);
    await _fetchCharactersPosts(characterTags);
  }

  Future<void> _fetchCharactersPosts(
    List<String> tags,
  ) async {
    for (final tag in tags) {
      if (state.recommends.any((e) => e.tag == tag)) continue;

      final posts = tagCache.containsKey(tag)
          ? tagCache[tag]!
          : await getPostsOrEmpty(tag, 1);

      tagCache[tag] = posts;

      state = state.copyWith(
        recommends: [
          ...state.recommends,
          Recommend(
            type: RecommendType.character,
            title: tag.removeUnderscoreWithSpace(),
            tag: tag,
            posts: posts.where((e) => !e.isFlash).toList(),
          ),
        ],
      );
    }
  }

  Future<void> _fetchArtistPosts(
    List<String> tags,
  ) async {
    for (final tag in tags) {
      if (state.recommends.any((e) => e.tag == tag)) continue;
      final posts = tagCache.containsKey(tag)
          ? tagCache[tag]!
          : await getPostsOrEmpty(tag, 1);

      tagCache[tag] = posts;

      state = state.copyWith(
        recommends: [
          ...state.recommends,
          Recommend(
            type: RecommendType.artist,
            title: tag.removeUnderscoreWithSpace(),
            tag: tag,
            posts: posts.where((e) => !e.isFlash).toList(),
          ),
        ],
      );
    }
  }
}
