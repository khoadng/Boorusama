// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/szurubooru/favorites/favorites.dart';
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'create_szurubooru_config_page.dart';
import 'szurubooru_home_page.dart';
import 'szurubooru_post_details_page.dart';

class SzurubooruBuilder
    with
        PostCountNotSupportedMixin,
        DefaultThumbnailUrlMixin,
        ArtistNotSupportedMixin,
        CharacterNotSupportedMixin,
        LegacyGranularRatingOptionsBuilderMixin,
        UnknownMetatagsMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultHomeMixin,
        DefaultTagColorMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultPostGesturesHandlerMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin,
        DefaultBooruUIMixin
    implements BooruBuilder {
  SzurubooruBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
      }) =>
          CreateBooruConfigScope(
            id: id,
            config: BooruConfig.defaultConfig(
              booruType: id.booruType,
              url: id.url,
              customDownloadFileNameFormat: null,
            ),
            child: CreateSzurubooruConfigPage(
              backgroundColor: backgroundColor,
            ),
          );

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) =>
          UpdateBooruConfigScope(
            id: id,
            child: CreateSzurubooruConfigPage(
              backgroundColor: backgroundColor,
              initialTab: initialTab,
            ),
          );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, postId) => SzurubooruCommentPage(
            postId: postId,
            useAppBar: useAppBar,
          );

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
  HomePageBuilder get homePageBuilder =>
      (context, config) => SzurubooruHomePage(
            config: config,
          );

  @override
  SearchPageBuilder get searchPageBuilder => (context, initialQuery) =>
      SzurubooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      (context, config, payload) => PostDetailsLayoutSwitcher(
            initialIndex: payload.initialIndex,
            posts: payload.posts,
            scrollController: payload.scrollController,
            desktop: (controller) => SzurubooruPostDetailsDesktopPage(
              initialIndex: controller.currentPage.value,
              controller: controller,
              posts: payload.posts,
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
            mobile: (controller) => SzurubooruPostDetailsPage(
              initialPage: controller.currentPage.value,
              controller: controller,
              posts: payload.posts,
              onExit: (page) => controller.onExit(page),
              onPageChanged: (page) => controller.setPage(page),
            ),
          );

  @override
  final DownloadFilenameGenerator<Post> downloadFilenameBuilder =
      DownloadFileNameBuilder<Post>(
    defaultFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    defaultBulkDownloadFileNameFormat: kGelbooruV2CustomDownloadFileNameFormat,
    sampleData: kDanbooruPostSamples,
    tokenHandlers: {
      'width': (post, config) => post.width.toString(),
      'height': (post, config) => post.height.toString(),
      'source': (post, config) => post.source.url,
    },
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
              contentBuilder: (context) => const AppHtml(
                data:
                    'You need to log in to use <b>Szurubooru</b> tag completion.',
              ),
            )
          : const SizedBox.shrink(),
      initialQuery: initialQuery,
      fetcher: (page, controller) => ref
          .read(szurubooruPostRepoProvider(config))
          .getPosts(controller.rawTagsString, page),
    );
  }
}

class SzurubooruCommentPage extends ConsumerWidget {
  const SzurubooruCommentPage({
    super.key,
    required this.postId,
    required this.useAppBar,
  });

  final int postId;
  final bool useAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(szurubooruClientProvider(ref.watchConfig));

    return CommentPageScaffold(
      postId: postId,
      useAppBar: useAppBar,
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
        fetcher: (page) =>
            ref.read(szurubooruPostRepoProvider(config)).getPosts(query, page));
  }
}
