// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru_v2/artists/artists.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/posts/character_post_list.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

final gelbooruV2PostDetailsArtistMapProvider = StateProvider.autoDispose(
  (ref) => <int, List<String>>{},
);

final gelbooruV2PostDetailsCharacterMapProvider = StateProvider.autoDispose(
  (ref) => <int, Set<String>>{},
);

class GelbooruV2PostDetailsPage extends ConsumerStatefulWidget {
  const GelbooruV2PostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<GelbooruV2Post> posts;
  final void Function(int page) onExit;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<GelbooruV2PostDetailsPage> createState() =>
      _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruV2PostDetailsPage> {
  List<GelbooruV2Post> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChangeIndexed: widget.onPageChanged,
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      fileDetailsBuilder: (context, post) => DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
      sliverRelatedPostsBuilder: (context, post) => post.hasParent
          ? ref.watch(gelbooruV2ChildPostsProvider(post.parentId!)).maybeWhen(
                data: (data) => RelatedPostsSection(
                  title: 'Child posts',
                  posts: data,
                  imageUrl: (post) => post.sampleImageUrl,
                  onTap: (index) => goToPostDetailsPage(
                    context: context,
                    posts: data,
                    initialIndex: index,
                  ),
                ),
                orElse: () => const SliverSizedBox.shrink(),
              )
          : const SliverSizedBox.shrink(),
      sliverArtistPostsBuilder: (context, post) => ref
          .watch(gelbooruV2PostDetailsArtistMapProvider)
          .lookup(post.id)
          .fold(
            () => [],
            (tags) => tags.isNotEmpty
                ? tags
                    .map((tag) => ArtistPostList2(
                          tag: tag,
                          builder: (tag) => ref
                              .watch(gelbooruV2ArtistPostsProvider(tag))
                              .maybeWhen(
                                data: (data) => SliverPreviewPostGrid(
                                  posts: data,
                                  onTap: (postIdx) => goToPostDetailsPage(
                                    context: context,
                                    posts: data,
                                    initialIndex: postIdx,
                                  ),
                                  imageUrl: (item) => item.sampleImageUrl,
                                ),
                                orElse: () =>
                                    const SliverPreviewPostGridPlaceholder(
                                  itemCount: 30,
                                ),
                              ),
                        ))
                    .toList()
                : [],
          ),
      sliverCharacterPostsBuilder: (context, post) => ref
          .watch(gelbooruV2PostDetailsCharacterMapProvider)
          .lookup(post.id)
          .fold(
            () => const SliverSizedBox.shrink(),
            (tags) => tags.isNotEmpty
                ? CharacterPostList(
                    tags: tags,
                  )
                : const SliverSizedBox.shrink(),
          ),
      tagListBuilder: (context, post) => GelbooruV2TagsTile(
        post: post,
        onTagsLoaded: (tags) => _setTags(post, tags),
      ),
    );
  }

  void _setTags(
    GelbooruV2Post post,
    List<TagGroupItem> tags,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      ref.setGelbooruPostDetailsArtistMap(
        post: post,
        tags: tags,
      );

      ref.setGelbooruPostDetailsCharacterMap(
        post: post,
        tags: tags,
      );
    });
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
    required this.post,
    this.onTagsLoaded,
  });

  final Post post;
  final void Function(List<TagGroupItem> tags)? onTagsLoaded;

  @override
  ConsumerState<GelbooruV2TagsTile> createState() => _GelbooruV2TagsTileState();
}

class _GelbooruV2TagsTileState extends ConsumerState<GelbooruV2TagsTile> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      ref.listen(gelbooruV2TagsFromIdProvider(widget.post.id),
          (previous, next) {
        next.when(
          data: (data) {
            if (!mounted) return;

            if (data.isNotEmpty) {
              if (widget.onTagsLoaded != null) {
                widget.onTagsLoaded!(createTagGroupItems(data));
              }
            }

            if (data.isEmpty && widget.post.tags.isNotEmpty) {
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

    return error == null
        ? TagsTile(
            tags: expanded
                ? ref
                    .watch(gelbooruV2TagsFromIdProvider(widget.post.id))
                    .maybeWhen(
                      data: (data) => createTagGroupItems(data),
                      orElse: () => null,
                    )
                : null,
            post: widget.post,
            onExpand: () => setState(() => expanded = true),
            onCollapse: () {
              // Don't set expanded to false to prevent rebuilding the tags list
              setState(() => error = null);
            },
            onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
          )
        : BasicTagList(
            tags: widget.post.tags.toList(),
            onTap: (tag) => goToSearchPage(context, tag: tag),
          );
  }
}
