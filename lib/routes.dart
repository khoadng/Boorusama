import 'package:boorusama/presentation/accounts/account_info/account_info_page.dart';
import 'package:boorusama/presentation/post_detail/post_image_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'domain/posts/post.dart';
import 'presentation/home/home_page.dart';
import 'presentation/post_detail/post_detail_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final postDetailHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final post = context.settings.arguments as Post;

  return PostDetailPage(post: post);
});

final postDetailImageHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final post = context.settings.arguments as Post;

  return PostImagePage(post: post);
});

final userHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  final String userId = params["id"][0];

  return AccountInfoPage(accountId: int.parse(userId));
});
