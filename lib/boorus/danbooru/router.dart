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
          handler: artistHandler, transitionType: TransitionType.inFromRight)
      ..define('/character',
          handler: characterHandler, transitionType: TransitionType.inFromRight)
      ..define('/post/detail',
          handler: postDetailHandler,
          transitionType: TransitionType.inFromRight)
      ..define('/posts/search',
          handler: postSearchHandler, transitionType: TransitionType.fadeIn)
      ..define('/posts/image',
          handler: postDetailImageHandler,
          transitionType: TransitionType.inFromRight)
      ..define('/users/profile',
          handler: userHandler, transitionType: TransitionType.inFromRight)
      ..define('/login',
          handler: loginHandler, transitionType: TransitionType.inFromRight)
      ..define('/settings',
          handler: settingsHandler, transitionType: TransitionType.inFromRight)
      ..define('/pool/detail',
          handler: poolDetailHandler,
          transitionType: TransitionType.inFromRight)
      ..define('/favorites',
          handler: favoritesHandler, transitionType: TransitionType.inFromRight)
      ..define('/users/blacklisted_tags',
          handler: blacklistedTagsHandler,
          transitionType: TransitionType.inFromRight);
  }
}
