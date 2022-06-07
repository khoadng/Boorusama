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
    router.define("/", handler: rootHandler);

    router.define("/artist",
        handler: artistHandler, transitionType: TransitionType.inFromRight);

    router.define("/posts/search",
        handler: postSearchHandler, transitionType: TransitionType.fadeIn);

    router.define("/posts/image",
        handler: postDetailImageHandler,
        transitionType: TransitionType.inFromRight);

    router.define("/users/profile",
        handler: userHandler, transitionType: TransitionType.inFromRight);

    router.define("/login",
        handler: loginHandler, transitionType: TransitionType.inFromRight);

    router.define("/settings",
        handler: settingsHandler, transitionType: TransitionType.inFromRight);
  }
}
