// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/boorus/szurubooru/post_votes/szurubooru_post_action_toolbar.dart';
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/core/comments/comments.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/create.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/html.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'create_szurubooru_config_page.dart';
import 'szurubooru_home_page.dart';
import 'szurubooru_post.dart';
import 'szurubooru_post_details_page.dart';

class SzurubooruBuilder
    with
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
      (context) => const SzurubooruFavoritesPage();

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const SzurubooruHomePage();

  @override
  SearchPageBuilder get searchPageBuilder => (context, initialQuery) =>
      SzurubooruSearchPage(initialQuery: initialQuery);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
        final posts = payload.posts.map((e) => e as SzurubooruPost).toList();

        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          posts: posts,
          scrollController: payload.scrollController,
          child: const DefaultPostDetailsPage<SzurubooruPost>(),
        );
      };

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

  @override
  final PostDetailsUIBuilder postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) => const SzurubooruPostActionToolbar(),
    },
    full: {
      DetailsPart.toolbar: (context) => const SzurubooruPostActionToolbar(),
      DetailsPart.stats: (context) => const SzurubooruStatsTileSection(),
      DetailsPart.tags: (context) => const SzurubooruTagListSection(),
      DetailsPart.fileDetails: (context) =>
          const SzurubooruFileDetailsSection(),
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
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(szurubooruPostRepoProvider(config));

    return SearchPageScaffold(
      noticeBuilder: (context) => !config.auth.hasLoginDetails()
          ? InfoContainer(
              contentBuilder: (context) => const AppHtml(
                data:
                    'You need to log in to use <b>Szurubooru</b> tag completion.',
              ),
            )
          : const SizedBox.shrink(),
      initialQuery: initialQuery,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller, page),
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
    final client = ref.watch(szurubooruClientProvider(ref.watchConfigAuth));

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
  const SzurubooruFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      child: SzurubooruFavoritesPageInternal(
        username: config.login!,
      ),
    );
  }
}

class SzurubooruFavoritesPageInternal extends ConsumerWidget {
  const SzurubooruFavoritesPageInternal({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:${config.auth.login?.replaceAll(' ', '_')}';

    return FavoritesPageScaffold(
        favQueryBuilder: () => query,
        fetcher: (page) =>
            ref.read(szurubooruPostRepoProvider(config)).getPosts(query, page));
  }
}
