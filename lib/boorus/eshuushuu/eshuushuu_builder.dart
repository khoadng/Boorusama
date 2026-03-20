// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/boorus/defaults/widgets.dart';
import '../../core/boorus/engine/types.dart';
import '../../core/configs/config/providers.dart';
import '../../core/configs/config/types.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/posts/details/types.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_parts/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/search/search/routes.dart';
import '../../core/search/search/widgets.dart';
import 'comments/widgets.dart';
import 'configs/widgets.dart';
import 'favorites/widgets.dart';
import 'home/widgets.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';
import 'users/routes.dart';

class EshuushuuBuilder extends BaseBooruBuilder {
  EshuushuuBuilder();

  @override
  CommentPageBuilder? get commentPageBuilder =>
      (context, useAppBar, post) => EshuushuuCommentPage(
        postId: post.id,
        useAppBar: useAppBar,
      );

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
        child: CreateEshuushuuConfigPage(
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
        child: CreateEshuushuuConfigPage(
          backgroundColor: backgroundColor,
          initialTab: initialTab,
        ),
      );

  @override
  HomePageBuilder get homePageBuilder =>
      (context) => const EshuushuuHomePage();

  @override
  FavoritesPageBuilder? get favoritesPageBuilder =>
      (context) => const EshuushuuFavoritesPage();

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, payload) {
    final posts = payload.posts.map((e) => e as EshuushuuPost).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<EshuushuuPost>(),
    );
  };

  @override
  SearchPageBuilder get searchPageBuilder =>
      (context, params) => EshuushuuSearchPage(
        params: params,
      );

  @override
  final postDetailsUIBuilder = PostDetailsUIBuilder(
    preview: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<EshuushuuPost>(),
    },
    full: {
      DetailsPart.toolbar: (context) =>
          const DefaultInheritedPostActionToolbar<EshuushuuPost>(),
      DetailsPart.source: (context) =>
          const DefaultInheritedSourceSection<EshuushuuPost>(),
      DetailsPart.tags: (context) => const EshuushuuInheritedTagsTile(),
      DetailsPart.fileDetails: (context) =>
          const _EshuushuuFileDetailsSection(),
    },
  );
}

class _EshuushuuFileDetailsSection extends ConsumerWidget {
  const _EshuushuuFileDetailsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<EshuushuuPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploader: switch ((post.uploaderId, post.uploaderName)) {
          (final int id, final String name) => UploaderFileDetailTile(
            uploaderName: name,
            onViewDetails: () => goToEshuushuuUserDetailsPage(
              ref,
              userId: id,
              username: name,
            ),
          ),
          _ => null,
        },
      ),
    );
  }
}

class EshuushuuSearchPage extends ConsumerWidget {
  const EshuushuuSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final postRepo = ref.watch(eshuushuuPostRepoProvider(config));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controller) =>
          postRepo.getPostsFromController(controller.tagSet, page),
    );
  }
}
