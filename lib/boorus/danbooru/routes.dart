import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'presentation/features/accounts/account_info/account_info_page.dart';
import 'presentation/features/home/home_page.dart';
import 'presentation/features/post_detail/post_detail_page.dart';
import 'presentation/features/post_detail/post_image_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final postDetailHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return PostDetailPage(
    post: args[0],
    heroTag: args[1],
  );
});

final postDetailImageHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final args = context.settings.arguments as List;

  return PostImagePage(
    post: args[0],
    heroTag: args[1],
  );
});

final userHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  final String userId = params["id"][0];

  return AccountInfoPage(accountId: int.parse(userId));
});
