// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluro/fluro.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/features/accounts/login/login_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/artists/artist_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/downloads/download_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'presentation/features/accounts/profile/profile_page.dart';
import 'presentation/features/home/home_page.dart';
import 'presentation/features/post_detail/post_image_page.dart';
import 'presentation/features/search/search_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final artistHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return ArtistPage(
    artistName: args[0],
    backgroundImageUrl: args[1],
  );
});

final downloadHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  return DownloadPage();
});

final postSearchHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return SearchPage(
    initialQuery: args[0],
  );
});

final postDetailImageHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return PostImagePage(
    post: args[0],
  );
});

final userHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  // final String userId = params["id"][0];

  return ProfilePage();
});

final loginHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

final settingsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SettingsPage();
});
