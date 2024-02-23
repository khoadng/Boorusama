// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/comments/comments.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
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
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  const SzurubooruBuilder({
    required this.postRepo,
    required this.autocompleteRepo,
  });

  final AutocompleteRepository autocompleteRepo;
  final PostRepository postRepo;

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
  FavoriteAdder? get favoriteAdder => (postId, ref) => ref
      .read(szurubooruFavoritesProvider(ref.readConfig).notifier)
      .add(postId)
      .then((value) => true);

  @override
  FavoriteRemover? get favoriteRemover => (postId, ref) => ref
      .read(szurubooruFavoritesProvider(ref.readConfig).notifier)
      .remove(postId)
      .then((value) => true);

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
  SearchPageBuilder get searchPageBuilder => (context, initialQuery) =>
      SzurubooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => BooruProvider(
            builder: (booruBuilder, ref) => PostDetailsPageScaffold(
              posts: payload.posts,
              initialIndex: payload.initialIndex,
              swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
              onExit: (page) => payload.scrollController?.scrollToIndex(page),
              onTagTap: (tag) => goToSearchPage(context, tag: tag),
              statsTileBuilder: (context, rawPost) =>
                  castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                        () => const SizedBox.shrink(),
                        (post) => Column(
                          children: [
                            const Divider(height: 8, thickness: 0.5),
                            SimplePostStatsTile(
                              totalComments: post.commentCount,
                              favCount: post.favoriteCount,
                              score: post.score,
                            ),
                          ],
                        ),
                      ),
              tagListBuilder: (context, post) => BasicTagList(
                tags: post.tags,
                unknownCategoryColor: ref.getTagColor(
                  context,
                  'general',
                ),
                onTap: (tag) => goToSearchPage(context, tag: tag),
              ),
              toolbarBuilder: (context, rawPost) =>
                  castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                        () => SimplePostActionToolbar(post: rawPost),
                        (post) => SzurubooruPostActionToolbar(post: post),
                      ),
              fileDetailsBuilder: (context, rawPost) => FileDetailsSection(
                post: rawPost,
                rating: rawPost.rating,
                uploader: castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                      () => null,
                      (post) => post.uploaderName != null
                          ? Text(
                              post.uploaderName!.replaceAll('_', ' '),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            )
                          : null,
                    ),
              ),
            ),
          );

  @override
  DownloadFilenameGenerator<Post> get downloadFilenameBuilder =>
      LegacyFilenameBuilder(
        generateFileName: (post, downloadUrl) => basename(downloadUrl),
      );
}

class SzurubooruSearchPage extends ConsumerWidget {
  const SzurubooruSearchPage({
    super.key,
    required this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return SearchPageScaffold(
      noticeBuilder: (context) => !config.hasLoginDetails()
          ? InfoContainer(
              contentBuilder: (context) => Html(
                  data:
                      'You need to log in to use <b>Szurubooru</b> tag completion.'),
            )
          : const SizedBox.shrink(),
      initialQuery: initialQuery,
      fetcher: (page, tags) =>
          ref.read(szurubooruPostRepoProvider(config)).getPosts(tags, page),
    );
  }
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
