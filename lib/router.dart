import 'package:boorusama/routes.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

@immutable
class AppRouter {
  static FluroRouter router = FluroRouter.appRouter;

  void setupRoutes() {
    router.define("/", handler: rootHandler);

    router.define("/posts",
        handler: postDetailHandler, transitionType: TransitionType.fadeIn);

    router.define("/posts/image",
        handler: postDetailImageHandler, transitionType: TransitionType.fadeIn);

    router.define("/users/:id", handler: userHandler);
  }
}
