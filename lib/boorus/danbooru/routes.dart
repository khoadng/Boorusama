// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/accounts/login/login_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'presentation/features/accounts/account_info/account_info_page.dart';
import 'presentation/features/home/home_page.dart';
import 'presentation/features/post_detail/post_detail_page.dart';
import 'presentation/features/post_detail/post_image_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final postSearchHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return SearchPage(
    initialQuery: args[0],
  );
});

final postDetailHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return PostDetailPage(
    post: args[0],
    intitialIndex: args[1],
    posts: args[2],
    onExit: args[3],
    onPostChanged: args[4],
    gridKey: args[5],
  );
});

final postDetailImageHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return PostImagePage(
    post: args[0],
    imageHeroTag: args[1],
  );
});

final userHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  final String userId = params["id"][0];

  return AccountInfoPage(accountId: int.parse(userId));
});

final loginHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

final settingsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SettingsPage();
});
