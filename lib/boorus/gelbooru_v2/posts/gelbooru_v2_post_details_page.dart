// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/tags/tag/tag.dart';
import '../artists/artists.dart';
import '../gelbooru_v2.dart';
import 'posts_v2.dart';

final gelbooruV2PostDetailsArtistMapProvider = StateProvider.autoDispose(
  (ref) => <int, List<String>>{},
);

final gelbooruV2PostDetailsCharacterMapProvider = StateProvider.autoDispose(
  (ref) => <int, Set<String>>{},
);

class GelbooruV2FileDetailsSection extends ConsumerWidget {
  const GelbooruV2FileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class GelbooruV2RelatedPostsSection extends ConsumerWidget {
  const GelbooruV2RelatedPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return post.hasParent
        ? ref
            .watch(
              gelbooruV2ChildPostsProvider(
                (ref.watchConfigFilter, ref.watchConfigSearch, post),
              ),
            )
            .maybeWhen(
              data: (data) => SliverRelatedPostsSection(
                title: 'Child posts',
                posts: data,
                imageUrl: (post) => post.sampleImageUrl,
                onViewAll: () => goToSearchPage(
                  context,
                  tag: post.relationshipQuery,
                ),
                onTap: (index) => goToPostDetailsPageFromPosts(
                  context: context,
                  posts: data,
                  initialIndex: index,
                  initialThumbnailUrl: data[index].sampleImageUrl,
                ),
              ),
              orElse: () => const SliverSizedBox.shrink(),
            )
        : const SliverSizedBox.shrink();
  }
}

class GelbooruV2CharacterPostsSection extends ConsumerWidget {
  const GelbooruV2CharacterPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return ref
        .watch(gelbooruV2PostDetailsCharacterMapProvider)
        .lookup(post.id)
        .fold(
          () => const SliverSizedBox.shrink(),
          (tags) => tags.isNotEmpty
              ? SliverCharacterPostList(
                  tags: tags,
                )
              : const SliverSizedBox.shrink(),
        );
  }
}

class GelbooruV2ArtistPostsSection extends ConsumerWidget {
  const GelbooruV2ArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return MultiSliver(
      children: ref
          .watch(gelbooruV2PostDetailsArtistMapProvider)
          .lookup(post.id)
          .fold(
            () => [],
            (tags) => tags.isNotEmpty
                ? tags
                    .map(
                      (tag) => SliverArtistPostList(
                        tag: tag,
                        child: ref
                            .watch(
                              gelbooruV2ArtistPostsProvider(
                                (
                                  ref.watchConfigFilter,
                                  ref.watchConfigSearch,
                                  tag
                                ),
                              ),
                            )
                            .maybeWhen(
                              data: (data) => SliverPreviewPostGrid(
                                posts: data,
                                onTap: (postIdx) =>
                                    goToPostDetailsPageFromPosts(
                                  context: context,
                                  posts: data,
                                  initialIndex: postIdx,
                                  initialThumbnailUrl:
                                      data[postIdx].sampleImageUrl,
                                ),
                                imageUrl: (item) => item.sampleImageUrl,
                              ),
                              orElse: () =>
                                  const SliverPreviewPostGridPlaceholder(),
                            ),
                      ),
                    )
                    .toList()
                : [],
          ),
    );
  }
}

extension GelbooruV2ArtistMapProviderX on WidgetRef {
  void setGelbooruPostDetailsArtistMap({
    required Post post,
    required List<TagGroupItem> tags,
  }) {
    final group =
        tags.firstWhereOrNull((tag) => tag.groupName.toLowerCase() == 'artist');

    if (group == null) return;
    final map = read(gelbooruV2PostDetailsArtistMapProvider);

    map[post.id] = group.tags.map((e) => e.rawName).toList();

    read(gelbooruV2PostDetailsArtistMapProvider.notifier).state = {
      ...map,
    };
  }

  void setGelbooruPostDetailsCharacterMap({
    required Post post,
    required List<TagGroupItem> tags,
  }) {
    final group = tags.firstWhereOrNull(
      (tag) => tag.groupName.toLowerCase() == 'character',
    );

    if (group == null) return;
    final map = read(gelbooruV2PostDetailsCharacterMapProvider);

    map[post.id] = group.tags.map((e) => e.rawName).toSet();

    read(gelbooruV2PostDetailsCharacterMapProvider.notifier).state = {
      ...map,
    };
  }
}

class GelbooruV2TagsTile extends ConsumerStatefulWidget {
  const GelbooruV2TagsTile({
    super.key,
  });

  @override
  ConsumerState<GelbooruV2TagsTile> createState() => _GelbooruV2TagsTileState();
}

class _GelbooruV2TagsTileState extends ConsumerState<GelbooruV2TagsTile> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    if (expanded) {
      ref.listen(gelbooruV2TagsFromIdProvider(post.id), (previous, next) {
        next.when(
          data: (data) {
            if (!mounted) return;

            if (data.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (!mounted) return;
                final groups = createTagGroupItems(data);

                ref
                  ..setGelbooruPostDetailsArtistMap(
                    post: post,
                    tags: groups,
                  )
                  ..setGelbooruPostDetailsCharacterMap(
                    post: post,
                    tags: groups,
                  );
              });
            }

            if (data.isEmpty && post.tags.isNotEmpty) {
              // Just a dummy data so the check below will branch into the else block
              setState(() => error = 'No tags found');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            if (!mounted) return;
            setState(() => this.error = error);
          },
        );
      });
    }

    return SliverToBoxAdapter(
      child: error == null
          ? TagsTile(
              tags: expanded
                  ? ref.watch(gelbooruV2TagsFromIdProvider(post.id)).maybeWhen(
                        data: (data) => createTagGroupItems(data),
                        orElse: () => null,
                      )
                  : null,
              post: post,
              onExpand: () => setState(() => expanded = true),
              onCollapse: () {
                // Don't set expanded to false to prevent rebuilding the tags list
                setState(() => error = null);
              },
              onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
            )
          : BasicTagList(
              tags: post.tags.toList(),
              onTap: (tag) => goToSearchPage(context, tag: tag),
            ),
    );
  }
}
