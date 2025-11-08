// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/comments/widgets.dart';
import '../../core/configs/config/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/search/search/routes.dart';
import '../../core/search/search/widgets.dart';
import '../../core/widgets/widgets.dart';
import '../../foundation/html.dart';
import 'configs/providers.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/widgets.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';

class SzurubooruBuilder extends BaseBooruBuilder {
  SzurubooruBuilder();

  @override
  CreateConfigPageBuilder get createConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
      }) => CreateBooruConfigScope(
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
  UpdateConfigPageBuilder get updateConfigPageBuilder =>
      (
        context,
        id, {
        backgroundColor,
        initialTab,
      }) => UpdateBooruConfigScope(
        id: id,
        child: CreateSzurubooruConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, post) => CommentPageScaffold(
        postId: post.id,
        useAppBar: useAppBar,
      );

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const SzurubooruFavoritesPage();

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const SzurubooruHomePage();

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => SzurubooruSearchPage(
        params: params,
      );

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as SzurubooruPost).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<SzurubooruPost>(),
    );
  };

  @override
  final postDetailsUIBuilder = kSzurubooruPostDetailsUIBuilder;
}

class SzurubooruSearchPage extends ConsumerWidget {
  const SzurubooruSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final loginDetails = ref.watch(szurubooruLoginDetailsProvider(config.auth));
    final postRepo = ref.watch(szurubooruPostRepoProvider(config));

    return SearchPageScaffold(
      landingViewBuilder: (controller) => DefaultMobileSearchLandingView(
        notice: !loginDetails.hasLogin()
            ? InfoContainer(
                contentBuilder: (context) => const AppHtml(
                  data:
                      'You need to log in to use <b>Szurubooru</b> tag completion.',
                ),
              )
            : null,
        controller: controller,
      ),
      params: params,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
    );
  }
}
