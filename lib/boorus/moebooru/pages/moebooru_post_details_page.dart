// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/providers.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details/widgets.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../core/widgets/widgets.dart';
import '../feats/favorites/favorites.dart';
import '../feats/posts/posts.dart';
import '../feats/tags/tags.dart';
import '../moebooru.dart';

final moebooruPostDetailTagGroupProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, Post>((ref, post) async {
  final config = ref.watchConfigAuth;

  final allTagMap = await ref.watch(moebooruAllTagsProvider(config).future);

  return createMoebooruTagGroupItems(post.tags, allTagMap);
});

List<TagGroupItem> createMoebooruTagGroupItems(
  Set<String> tagStrings,
  Map<String, Tag> allTagsMap,
) {
  final tags = <Tag>[];

  for (final tag in tagStrings) {
    if (allTagsMap.containsKey(tag)) {
      tags.add(allTagsMap[tag]!);
    }
  }

  final tagGroups = createTagGroupItems(tags);

  return tagGroups;
}

class MoebooruPostDetailsPage extends StatelessWidget {
  const MoebooruPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<MoebooruPost>(context);

    return MoebooruPostDetailsPageInternal(
      data: data,
    );
  }
}

class MoebooruPostDetailsPageInternal extends ConsumerStatefulWidget {
  const MoebooruPostDetailsPageInternal({
    required this.data,
    super.key,
  });

  final PostDetailsData<MoebooruPost> data;

  @override
  ConsumerState<MoebooruPostDetailsPageInternal> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState
    extends ConsumerState<MoebooruPostDetailsPageInternal> {
  late PostDetailsData<MoebooruPost> data = widget.data;

  List<MoebooruPost> get posts => data.posts;
  PostDetailsController<MoebooruPost> get controller => data.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteUsers(posts[controller.initialPage].id);
    });

    data.controller.currentPage.addListener(_onPageChanged);
  }

  @override
  void didUpdateWidget(covariant MoebooruPostDetailsPageInternal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      controller.currentPage.removeListener(_onPageChanged);
      setState(() {
        data = widget.data;
        controller.currentPage.addListener(_onPageChanged);
      });
    }
  }

  void _onPageChanged() {
    _loadFavoriteUsers(posts[controller.currentPage.value].id);
  }

  Future<void> _loadFavoriteUsers(int postId) async {
    final config = ref.readConfigAuth;
    final booru = ref.read(moebooruProvider);

    if (booru.supportsFavorite(config.url) && config.hasLoginDetails()) {
      return ref
          .read(moebooruFavoritesProvider(postId).notifier)
          .loadFavoriteUsers();
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.currentPage.removeListener(_onPageChanged);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      topRightButtonsBuilder: (controller) => [
        GeneralMoreActionButton(
          post: InheritedPost.of<MoebooruPost>(context),
          onStartSlideshow: config.hasLoginDetails()
              ? null
              : () => controller.startSlideshow(),
        ),
      ],
    );
  }
}

class MoebooruTagListSection extends ConsumerWidget {
  const MoebooruTagListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);

    return SliverToBoxAdapter(
      child: TagsTile(
        initialExpanded: true,
        post: post,
        tags: ref.watch(moebooruPostDetailTagGroupProvider(post)).maybeWhen(
              data: (tags) => tags,
              orElse: () => null,
            ),
        onTagTap: (tag) => goToSearchPage(
          context,
          tag: tag.rawName,
        ),
      ),
    );
  }
}

class MoebooruCharacterListSection extends ConsumerWidget {
  const MoebooruCharacterListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<MoebooruPost>(context);

    return ref.watch(moebooruPostDetailTagGroupProvider(post)).maybeWhen(
          data: (tags) {
            final artistTags = _extractArtist(config, tags);
            final characterTags = _extractCharacter(config, tags);

            return artistTags != null && artistTags.isNotEmpty
                ? ref
                    .watch(
                      moebooruPostDetailsArtistProvider(
                        (
                          ref.watchConfigFilter,
                          ref.watchConfigSearch,
                          artistTags.first
                        ),
                      ),
                    )
                    .maybeWhen(
                      data: (_) {
                        return characterTags != null && characterTags.isNotEmpty
                            ? SliverCharacterPostList(tags: characterTags)
                            : const SliverSizedBox.shrink();
                      },
                      orElse: () => const SliverSizedBox.shrink(),
                    )
                : const SliverSizedBox.shrink();
          },
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}

Set<String>? _extractCharacter(
  BooruConfigAuth booruConfig,
  List<TagGroupItem>? tagGroups,
) {
  if (tagGroups == null) return null;

  final tag = tagGroups.firstWhereOrNull(
    (e) => TagCategory.fromLegacyId(e.category) == TagCategory.character(),
  );
  final characterTags = tag?.tags.map((e) => e.rawName).toSet();
  return characterTags;
}

List<String>? _extractArtist(
  BooruConfigAuth booruConfig,
  List<TagGroupItem>? tagGroups,
) {
  if (tagGroups == null) return null;

  final tag = tagGroups.firstWhereOrNull(
    (e) => TagCategory.fromLegacyId(e.category) == TagCategory.artist(),
  );
  final artistTags = tag?.tags.map((e) => e.rawName).toList();
  return artistTags;
}

class MoebooruArtistPostsSection extends ConsumerWidget {
  const MoebooruArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<MoebooruPost>(context);

    return MultiSliver(
      children: ref.watch(moebooruPostDetailTagGroupProvider(post)).maybeWhen(
            data: (tags) {
              final artistTags = _extractArtist(config, tags);

              return artistTags != null && artistTags.isNotEmpty
                  ? artistTags
                      .map(
                        (tag) => SliverArtistPostList(
                          tag: tag,
                          child: ref
                              .watch(
                                moebooruPostDetailsArtistProvider(
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
                                        data[postIdx].thumbnailImageUrl,
                                  ),
                                  imageUrl: (item) => item.thumbnailImageUrl,
                                ),
                                orElse: () =>
                                    const SliverPreviewPostGridPlaceholder(),
                              ),
                        ),
                      )
                      .toList()
                  : [];
            },
            orElse: () => [],
          ),
    );
  }
}

class MoebooruFileDetailsSection extends ConsumerWidget {
  const MoebooruFileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class MoebooruPostDetailsActionToolbar extends ConsumerWidget {
  const MoebooruPostDetailsActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<MoebooruPost>(context);
    final booru = ref.watch(moebooruProvider);

    return SliverToBoxAdapter(
      child: booru.supportsFavorite(config.url)
          ? _Toolbar(post: post)
          : DefaultPostActionToolbar(post: post),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(moebooruFavoritesProvider(post.id).notifier);

    return SimplePostActionToolbar(
      isFaved:
          ref.watch(moebooruFavoritesProvider(post.id))?.contains(config.login),
      addFavorite: () => ref
          .read(moebooruClientProvider(config))
          .favoritePost(postId: post.id)
          .then((value) {
        notifier.clear();
      }),
      removeFavorite: () => ref
          .read(moebooruClientProvider(config))
          .unfavoritePost(postId: post.id)
          .then((value) {
        notifier.clear();
      }),
      isAuthorized: config.hasLoginDetails(),
      forceHideFav: !config.hasLoginDetails(),
      post: post,
    );
  }
}
