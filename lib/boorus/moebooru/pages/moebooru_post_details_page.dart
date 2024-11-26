// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

final moebooruPostDetailTagGroupProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, Post>((ref, post) async {
  final config = ref.watchConfig;

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
    super.key,
    required this.data,
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

  //FIXME: Need to test this carefully
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
    final config = ref.readConfig;
    final booru = config.createBooruFrom(ref.read(booruFactoryProvider));

    await booru?.whenMoebooru(
      data: (data) async {
        if (data.supportsFavorite(config.url) && config.hasLoginDetails()) {
          return ref
              .read(moebooruFavoritesProvider(postId).notifier)
              .loadFavoriteUsers();
        }
        return;
      },
      orElse: () => Future.value(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.currentPage.removeListener(_onPageChanged);
  }

  @override
  Widget build(BuildContext context) {
    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      topRightButtonsBuilder: (controller) => [
        GeneralMoreActionButton(
          post: InheritedPost.of<MoebooruPost>(context),
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
    final config = ref.watchConfig;
    final post = InheritedPost.of<MoebooruPost>(context);

    return ref.watch(moebooruPostDetailTagGroupProvider(post)).maybeWhen(
          data: (tags) {
            final artistTags = _extractArtist(config, tags);
            final characterTags = _extractCharacter(config, tags);

            return artistTags != null && artistTags.isNotEmpty
                ? ref
                    .watch(moebooruPostDetailsArtistProvider(artistTags.first))
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
  BooruConfig booruConfig,
  List<TagGroupItem>? tagGroups,
) {
  if (tagGroups == null) return null;

  final tag = tagGroups.firstWhereOrNull(
      (e) => TagCategory.fromLegacyId(e.category) == TagCategory.character());
  final characterTags = tag?.tags.map((e) => e.rawName).toSet();
  return characterTags;
}

List<String>? _extractArtist(
  BooruConfig booruConfig,
  List<TagGroupItem>? tagGroups,
) {
  if (tagGroups == null) return null;

  final tag = tagGroups.firstWhereOrNull(
      (e) => TagCategory.fromLegacyId(e.category) == TagCategory.artist());
  final artistTags = tag?.tags.map((e) => e.rawName).toList();
  return artistTags;
}

class MoebooruArtistPostsSection extends ConsumerWidget {
  const MoebooruArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
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
                              .watch(moebooruPostDetailsArtistProvider(tag))
                              .maybeWhen(
                                data: (data) => SliverPreviewPostGrid(
                                  posts: data,
                                  onTap: (postIdx) =>
                                      goToPostDetailsPageFromPosts(
                                    context: context,
                                    posts: data,
                                    initialIndex: postIdx,
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
    final config = ref.watchConfig;
    final post = InheritedPost.of<MoebooruPost>(context);
    final booru = config.createBooruFrom(ref.watch(booruFactoryProvider));

    return SliverToBoxAdapter(
      child: booru?.whenMoebooru(
              data: (data) => data.supportsFavorite(config.url)
                  ? _Toolbar(post: post)
                  : DefaultPostActionToolbar(post: post),
              orElse: () => DefaultPostActionToolbar(post: post)) ??
          DefaultPostActionToolbar(post: post),
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
    final config = ref.watchConfig;
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
