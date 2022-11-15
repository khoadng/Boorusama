// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/routes.dart';

@immutable
class AppRouter {
  static final FluroRouter router = FluroRouter.appRouter;

  void setupRoutes() {
    router
      ..define('/', handler: rootHandler)
      ..define(
        '/artist',
        handler: artistHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/character',
        handler: characterHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/post/detail',
        handler: postDetailHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/posts/search',
        handler: postSearchHandler,
        transitionType: TransitionType.fadeIn,
      )
      ..define(
        '/users/profile',
        handler: userHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/login',
        handler: loginHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/settings',
        handler: settingsHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/pool/detail',
        handler: poolDetailHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/favorites',
        handler: favoritesHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/bulk_download',
        handler: bulkDownloadHandler,
        transitionType: TransitionType.inFromBottom,
      )
      ..define(
        '/saved_search',
        handler: savedSearchHandler,
        transitionType: TransitionType.material,
      )
      ..define(
        '/saved_search/edit',
        handler: savedSearchEditHandler,
        transitionType: TransitionType.inFromRight,
      )
      ..define(
        '/users/blacklisted_tags',
        handler: blacklistedTagsHandler,
        transitionType: TransitionType.material,
      );
  }
}

void goToDetailPage({
  required BuildContext context,
  required List<PostData> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
  PostBloc? postBloc,
}) {
  AppRouter.router.navigateTo(
    context,
    '/post/detail',
    routeSettings: RouteSettings(
      arguments: [
        posts,
        initialIndex,
        scrollController,
        postBloc,
      ],
    ),
  );
}
