// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/routes.dart';

@immutable
class AppRouter {
  static FluroRouter router = FluroRouter.appRouter;

  void setupRoutes() {
    router
      ..define('/', handler: rootHandler)
      ..define('/artist',
          handler: artistHandler, transitionType: TransitionType.material)
      ..define('/character',
          handler: characterHandler, transitionType: TransitionType.material)
      ..define('/post/detail',
          handler: postDetailHandler, transitionType: TransitionType.material)
      ..define('/posts/search',
          handler: postSearchHandler, transitionType: TransitionType.fadeIn)
      ..define('/posts/image',
          handler: postDetailImageHandler,
          transitionType: TransitionType.fadeIn)
      ..define('/users/profile',
          handler: userHandler, transitionType: TransitionType.material)
      ..define('/login',
          handler: loginHandler, transitionType: TransitionType.material)
      ..define('/settings',
          handler: settingsHandler, transitionType: TransitionType.material)
      ..define('/pool/detail',
          handler: poolDetailHandler, transitionType: TransitionType.material)
      ..define('/favorites',
          handler: favoritesHandler, transitionType: TransitionType.material)
      ..define('/users/blacklisted_tags',
          handler: blacklistedTagsHandler,
          transitionType: TransitionType.material);
  }
}
