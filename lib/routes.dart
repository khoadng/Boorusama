import 'package:boorusama/presentation/accounts/account_info/account_info_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'presentation/home/home_page.dart';
import 'presentation/post_detail/post_detail_page.dart';

final rootHandler = Handler(
  handlerFunc: (context, parameters) => HomePage(),
);

final postDetailHandler = Handler(handlerFunc: (
  BuildContext context,
  Map<String, List<String>> params,
) {
  final String postId = params["id"][0];

  return PostDetailPage(postId: int.parse(postId));
});

final userHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  final String userId = params["id"][0];

  return AccountInfoPage(accountId: int.parse(userId));
});
