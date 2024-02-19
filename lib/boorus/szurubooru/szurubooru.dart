// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/comments/comments.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';
import 'create_szurubooru_config_page.dart';
import 'szurubooru_post.dart';

class SzurubooruBuilder
    with
        PostCountNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        NoteNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        NoGranularRatingQueryBuilderMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const SzurubooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
    required this.client,
  });

  final AutocompleteRepository autocompleteRepo;
  final PostRepository postRepo;
  final SzurubooruClient client;

  @override
  AutocompleteFetcher get autocompleteFetcher =>
      (query) => autocompleteRepo.getAutocomplete(query);

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        url,
        booruType, {
        backgroundColor,
      }) =>
          CreateSzurubooruConfigPage(
            config: BooruConfig.defaultConfig(
              booruType: booruType,
              url: url,
              customDownloadFileNameFormat: null,
            ),
            backgroundColor: backgroundColor,
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        config, {
        backgroundColor,
      }) =>
          CreateSzurubooruConfigPage(
            config: config,
            backgroundColor: backgroundColor,
          );

  @override
  PostFetcher get postFetcher =>
      (page, tags, {limit}) => postRepo.getPosts(tags, page, limit: limit);

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => SzurubooruCommentPage(postId: postId);

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context, config) => SzurubooruFavoritesPage(username: config.name);

  @override
  FavoriteAdder? get favoriteAdder => (postId) => client
      .addToFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  FavoriteRemover? get favoriteRemover => (postId) => client
      .removeFromFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  HomePageBuilder get homePageBuilder => (context, config) => HomePageScaffold(
        onPostTap:
            (context, posts, post, scrollController, settings, initialIndex) =>
                goToPostDetailsPage(
          context: context,
          posts: posts,
          initialIndex: initialIndex,
        ),
        mobileMenuBuilder: (context, controller) => [
          if (config.hasLoginDetails()) ...[
            SideMenuTile(
              icon: const Icon(Symbols.favorite),
              title: Text('profile.favorites'.tr()),
              onTap: () => goToFavoritesPage(context),
            ),
          ]
        ],
        onSearchTap: () => goToSearchPage(context),
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder, ref) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
              tagListBuilder: (context, post) => BasicTagList(
                tags: post.tags,
                unknownCategoryColor: ref.getTagColor(
                  context,
                  'general',
                ),
                onTap: (tag) => goToSearchPage(context, tag: tag),
              ),
              toolbarBuilder: (context, post) =>
                  (post as SzurubooruPost).toOption().fold(
                        () => SimplePostActionToolbar(post: post),
                        (post) => SzurubooruPostActionToolbar(post: post),
                      ),
              fileDetailsBuilder: (context, post) => FileDetailsSection(
                post: post,
                rating: post.rating,
                uploader: (post as SimplePost).toOption().fold(
                    () => null,
                    (t) => t.uploaderName != null
                        ? Text(
                            post.uploaderName!.replaceAll('_', ' '),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          )
                        : null),
              ),
            ),
          );

  @override
  DownloadFilenameGenerator<Post> get downloadFilenameBuilder =>
      LegacyFilenameBuilder(
        generateFileName: (post, downloadUrl) => basename(downloadUrl),
      );
}

class SzurubooruCommentPage extends ConsumerWidget {
  const SzurubooruCommentPage({
    super.key,
    required this.postId,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(szurubooruClientProvider(ref.watchConfig));

    return CommentPageScaffold(
      postId: postId,
      fetcher: (id) => client.getComments(postId: postId).then(
            (value) => value
                .map((e) => SimpleComment(
                      id: e.id ?? 0,
                      body: e.text ?? '',
                      createdAt: e.creationTime != null
                          ? DateTime.parse(e.creationTime!)
                          : DateTime(1),
                      updatedAt: e.lastEditTime != null
                          ? DateTime.parse(e.lastEditTime!)
                          : DateTime(1),
                      creatorName: e.user?.name ?? '',
                      creatorId: null,
                    ))
                .toList(),
          ),
    );
  }
}

class SzurubooruFavoritesPage extends ConsumerWidget {
  const SzurubooruFavoritesPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'fav:${config.login?.replaceAll(' ', '_')}';

    return FavoritesPageScaffold(
        favQueryBuilder: () => query,
        fetcher: (page) => ref
            .read(szurubooruPostRepoProvider(config))
            .getPosts([query], page));
  }
}

class SzurubooruPostActionToolbar extends ConsumerWidget {
  const SzurubooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final SzurubooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final isFaved = ref.watch(szurubooruFavoriteProvider(post.id));

    return SimplePostActionToolbar(
      post: post,
      isFaved: isFaved,
      isAuthorized: config.hasLoginDetails(),
      addFavorite: () =>
          ref.read(szurubooruFavoritesProvider(config).notifier).add(post.id),
      removeFavorite: () => ref
          .read(szurubooruFavoritesProvider(config).notifier)
          .remove(post.id),
    );
  }
}
