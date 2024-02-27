// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/moebooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/core/widgets/posts/character_post_list.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/moebooru_comment_section.dart';
import 'widgets/moebooru_information_section.dart';
import 'widgets/moebooru_related_post_section.dart';

final moebooruPostDetailTagGroupProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>, Post>((ref, post) async {
  final config = ref.watchConfig;

  final allTagMap = await ref.watch(moebooruAllTagsProvider(config).future);

  return createMoebooruTagGroupItems(post.tags, allTagMap);
});

List<TagGroupItem> createMoebooruTagGroupItems(
  List<String> tagStrings,
  Map<String, Tag> allTagsMap,
) {
  final tags = <Tag>[];

  for (var tag in tagStrings) {
    if (allTagsMap.containsKey(tag)) {
      tags.add(allTagsMap[tag]!);
    }
  }

  final tagGroups = createTagGroupItems(tags);

  return tagGroups;
}

class MoebooruPostDetailsPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialPage,
    required this.onExit,
  });

  final List<MoebooruPost> posts;
  final int initialPage;
  final void Function(int page) onExit;

  @override
  ConsumerState<MoebooruPostDetailsPage> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState
    extends ConsumerState<MoebooruPostDetailsPage> {
  List<MoebooruPost> get posts => widget.posts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteUsers(posts[widget.initialPage].id);
    });
  }

  void _loadFavoriteUsers(int postId) async {
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
      orElse: () => Future.value(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final booru = config.createBooruFrom(ref.watch(booruFactoryProvider));

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialPage,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(
        context,
        tag: tag,
      ),
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      fileDetailsBuilder: (context, post) => FileDetailsSection(
        post: post,
        rating: post.rating,
        uploader: post.uploaderName != null
            ? Text(
                post.uploaderName!.replaceAll('_', ' '),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                ),
              )
            : null,
      ),
      sliverRelatedPostsBuilder: (context, post) =>
          MoebooruRelatedPostsSection(post: post),
      sliverArtistPostsBuilder: (context, post) => ref
          .watch(moebooruPostDetailTagGroupProvider(post))
          .maybeWhen(
            data: (tags) {
              final artistTags = _extractArtist(config, tags);

              return artistTags != null && artistTags.isNotEmpty
                  ? artistTags
                      .map(
                        (tag) => ArtistPostList2(
                          tag: tag,
                          builder: (tag) => ref
                              .watch(moebooruPostDetailsArtistProvider(tag))
                              .maybeWhen(
                                data: (data) => SliverPreviewPostGrid(
                                  posts: data,
                                  onTap: (postIdx) => goToPostDetailsPage(
                                    context: context,
                                    posts: data,
                                    initialIndex: postIdx,
                                  ),
                                  imageUrl: (item) => item.thumbnailImageUrl,
                                ),
                                orElse: () =>
                                    const SliverPreviewPostGridPlaceholder(
                                  itemCount: 30,
                                ),
                              ),
                        ),
                      )
                      .toList()
                  : [];
            },
            orElse: () => [],
          ),
      sliverCharacterPostsBuilder: (context, post) {
        return ref.watch(moebooruPostDetailTagGroupProvider(post)).maybeWhen(
              data: (tags) {
                final artistTags = _extractArtist(config, tags);
                final characterTags = _extractCharacter(config, tags);

                return artistTags != null && artistTags.isNotEmpty
                    ? ref
                        .watch(
                            moebooruPostDetailsArtistProvider(artistTags.first))
                        .maybeWhen(
                          data: (_) {
                            return characterTags != null &&
                                    characterTags.isNotEmpty
                                ? CharacterPostList(tags: characterTags)
                                : const SliverSizedBox.shrink();
                          },
                          orElse: () => const SliverSizedBox.shrink(),
                        )
                    : const SliverSizedBox.shrink();
              },
              orElse: () => const SliverSizedBox.shrink(),
            );
      },
      tagListBuilder: (context, post) => TagsTile(
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
      toolbarBuilder: (context, post) {
        final notifier = ref.watch(moebooruFavoritesProvider(post.id).notifier);

        return booru?.whenMoebooru(
                data: (data) => data.supportsFavorite(config.url)
                    ? SimplePostActionToolbar(
                        isFaved: ref
                            .watch(moebooruFavoritesProvider(post.id))
                            ?.contains(config.login),
                        addFavorite: () => ref
                            .read(moebooruClientProvider(config))
                            .favoritePost(postId: post.id)
                            .then((value) {
                          showSuccessToast('Favorited');
                          notifier.clear();
                        }),
                        removeFavorite: () => ref
                            .read(moebooruClientProvider(config))
                            .unfavoritePost(postId: post.id)
                            .then((value) {
                          showSuccessToast('Unfavorited');
                          notifier.clear();
                        }),
                        isAuthorized: config.hasLoginDetails(),
                        forceHideFav: !config.hasLoginDetails(),
                        post: post,
                      )
                    : SimplePostActionToolbar(post: post),
                orElse: () => SimplePostActionToolbar(post: post)) ??
            SimplePostActionToolbar(post: post);
      },
      commentsBuilder: (context, post) => MoebooruCommentSection(post: post),
      infoBuilder: (context, post) =>
          ref.watch(moebooruAllTagsProvider(config)).maybeWhen(
                data: (tags) {
                  final tagGroups =
                      createMoebooruTagGroupItems(post.tags, tags);

                  return MoebooruInformationSection(
                    post: post,
                    tags: tagGroups,
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
      onPageChanged: (post) {
        _loadFavoriteUsers(post.id);
      },
    );
  }

  List<String>? _extractArtist(
    BooruConfig booruConfig,
    List<TagGroupItem>? tagGroups,
  ) {
    if (tagGroups == null) return null;

    final tag = tagGroups.firstWhereOrNull(
        (e) => intToTagCategory(e.category) == TagCategory.artist);
    final artistTags = tag?.tags.map((e) => e.rawName).toList();
    return artistTags;
  }

  List<String>? _extractCharacter(
    BooruConfig booruConfig,
    List<TagGroupItem>? tagGroups,
  ) {
    if (tagGroups == null) return null;

    final tag = tagGroups.firstWhereOrNull(
        (e) => intToTagCategory(e.category) == TagCategory.character);
    final characterTags = tag?.tags.map((e) => e.rawName).toList();
    return characterTags;
  }
}
